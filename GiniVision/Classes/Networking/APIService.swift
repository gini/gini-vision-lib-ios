//
//  DocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

public typealias Extraction = GINIExtraction

enum Result<T> {
    case success(T)
    case failure(Error)
}

typealias UploadDocumentCompletion = (Result<GINIDocument>) -> Void

protocol APIServiceProtocol: class {
    
    var error: Error? { get }
    var isAnalyzing: Bool { get }
    var result: [String: Extraction]? { get }
    
    func analyze(document: GiniVisionDocument,
                 completion: @escaping (Result<[String: Extraction]>) -> Void)
    
    func getExtractions(from document: GINIDocument,
                        completion: @escaping (Result<[String: Extraction]>) -> Void)
    func cancelAnalysis()
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?)
    func sendFeedback(withResults results: [String: Extraction])
}

final class APIService: APIServiceProtocol {
    
    var error: Error?
    var giniSDK: GiniSDK?
    var isAnalyzing = false
    var result: [String: Extraction]?
    var sessionDocuments: [String: (GINIDocument?, BFCancellationTokenSource?)] = [:]
    
    enum AnalysisError: Error {
        case cancelled
        case documentCreation
        case unknown
    }
    
    func cancelAnalysis() {
        result = nil
        sessionDocuments.removeAll()
        error = nil
        isAnalyzing = false
    }
    
    init(sdk: GiniSDK?) {
        self.giniSDK = sdk
    }
    
    func getExtractions(from document: GINIDocument, completion: @escaping (Result<[String : Extraction]>) -> Void) {
        document.getExtractionsWith(self.cancellationTokenSource?.token)
            .continueWith(block: self.handleAnalysisResults(completion: completion))
    }
    
    func analyze(document: GiniVisionDocument,
                 completion: @escaping (Result<[String: Extraction]>) -> Void) {
        print("🔎 Started document analysis with size \(Double(document.data.count) / 1024.0)")
        
        cancelAnalysis()
        isAnalyzing = true
        
        upload(document: document) { [weak self] response in
            guard let `self` = self else { return }
            
            switch response {
            case .success(let createdDocument):
                self.getExtractions(from: createdDocument, completion: completion)
            case .failure(let error):
                let task: BFTask<AnyObject>

                if let error = error as? AnalysisError, error == .cancelled {
                    task = BFTask.cancelled()
                } else {
                    task = BFTask(error: error)
                }
                task.continueWith(block: self.handleAnalysisResults(completion: completion))
            }
        }
        
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        self.sessionDocuments[document.id] = (nil, cancellationTokenSource)
        
        _ = giniSDK?.sessionManager.getSession()
            .continueWith(block: getSessionBlock(cancelationToken: cancellationTokenSource.token))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK?.documentTaskManager.createDocument(withFilename: "fileName",
                                                                         from: document.data,
                                                                         docType: "",
                                                                         isPartialDocument: false,
                                                                         cancellationToken: token)
            }).continueWith(block: { task in
                if let createdDocument = task.result as? GINIDocument {
                    self.sessionDocuments[document.id] = (createdDocument, cancellationTokenSource)
                    print("📄 Created document with id: \(createdDocument.documentId ?? "")")
                    
                    completion?(.success(createdDocument))
                } else if task.isCancelled {
                    completion?(.failure(AnalysisError.cancelled))
                } else {
                    completion?(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
    }
    
    func createMultipageDocument(withSubdocumentURLs urls: [URL],
                                 cancelationToken token: BFCancellationToken,
                                 fileName: String,
                                 docType: String,
                                 completion: @escaping ((Result<GINIDocument>) -> Void)) {
        _ = giniSDK?.sessionManager.getSession()
            .continueWith(block: getSessionBlock(cancelationToken: token))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK?.documentTaskManager.createMultipageDocument(withSubDocumentsURLs: urls,
                                                                                  fileName: fileName,
                                                                                  docType: docType,
                                                                                  cancellationToken: token)
            }).continueWith(block: { task in
                if let document = task.result as? GINIDocument {
                    print("📄 Created document with id: \(document.documentId ?? "")")
                    
                    completion(.success(document))
                } else if task.isCancelled {
                    completion(.failure(AnalysisError.cancelled))
                } else {
                    completion(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
    }
    
    func sendFeedback(withResults results: [String: Extraction]) {
        _ = giniSDK?.sessionManager.getSession()
            .continueWith(block: getSessionBlock())
            .continueOnSuccessWith(block: { _ in return self.document?.getExtractions() })
            .continueOnSuccessWith(block: { (task: BFTask?) in
                if let extractions = task?.result as? NSMutableDictionary {
                    results.forEach { result in
                        extractions[result.key] = result.value
                    }
                    
                    return self.giniSDK?
                        .documentTaskManager?
                        .update(self.document)
                }
                
                return nil
            })
            .continueOnSuccessWith(block: { _ in return self.document?.getExtractions() })
            .continueWith(block: { (task: BFTask?) in
                guard let extractions = task?.result as? NSMutableDictionary else {
                    print("Error sending feedback for document with id: ",
                          String(describing: self.document?.documentId))
                    return nil
                }
                
                print("🚀 Feedback sent with \(extractions.count) extractions")
                return nil
            })
    }
}

// MARK: - File private methods

extension APIService {
    
    fileprivate func getSessionBlock(cancelationToken token: BFCancellationToken? = nil)
        -> ((BFTask<AnyObject>) -> Any?) {
            return {
                [weak self] (task: BFTask<AnyObject>?) -> Any! in
                guard let `self` = self else { return nil }
                
                if task?.error != nil {
                    return self.giniSDK?.sessionManager.logIn()
                }
                return task?.result
            }
    }
    
    fileprivate func handleAnalysisResults(completion: @escaping (Result<[String: Extraction]>) -> Void)
        -> ((BFTask<AnyObject>) -> Any?) {
            return { [weak self] task in
                guard let `self` = self else { return nil }
                
                if task.isCancelled {
                    print("❌ Cancelled analysis process)
                    completion(.failure(AnalysisError.documentCreation))
                    
                    return BFTask<AnyObject>.cancelled()
                }
                
                let finishedString = "Finished analysis process with"
                
                if let error = task.error {
                    self.error = error
                    print("❌", finishedString, "this error: \(error)")
                    
                    completion(.failure(error))
                } else if let result = task.result as? [String: Extraction] {
                    self.result = result
                    print("✅", finishedString, "no errors")
                    
                    completion(.success((result)))
                } else {
                    let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                    self.error = error
                    print("❌", finishedString, "this error: \(error)")
                    
                    completion(.failure(AnalysisError.unknown))
                }
                
                self.isAnalyzing = false
                
                return nil
            }
    }
    
}
