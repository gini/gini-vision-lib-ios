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

protocol APIServiceProtocol: class {
    
    var error: Error? { get }
    var isAnalyzing: Bool { get }
    var result: [String: Extraction]? { get }
    
    func analyze(document: GiniVisionDocument,
                 completion: @escaping (Result<[String: Extraction]>) -> Void)
    func cancelAnalysis()
    func create(document: GiniVisionDocument,
                cancelationToken token: BFCancellationToken,
                fileName: String,
                docType: String,
                completion: @escaping ((Result<GINIDocument>) -> Void))
    func sendFeedback(withResults results: [String: Extraction])
}

extension APIServiceProtocol {
    func create(document: GiniVisionDocument,
                cancelationToken token: BFCancellationToken,
                fileName: String,
                docType: String = "",
                completion: @escaping ((Result<GINIDocument>) -> Void)) {
        create(document: document,
               cancelationToken: token,
               fileName: fileName,
               docType: docType,
               completion: completion)
    }
}

final class APIService: APIServiceProtocol {
    
    fileprivate var cancellationTokenSource: BFCancellationTokenSource?
    var document: GINIDocument?
    var error: Error?
    var giniSDK: GiniSDK?
    var isAnalyzing = false
    var result: [String: Extraction]?
    
    enum AnalysisError: Error {
        case cancelled
        case documentCreation
        case unknown
    }
    
    func cancelAnalysis() {
        cancellationTokenSource?.cancel()
        cancellationTokenSource = nil
        result = nil
        document = nil
        error = nil
        isAnalyzing = false
    }
    
    init(sdk: GiniSDK?) {
        self.giniSDK = sdk
    }
    
    func analyze(document: GiniVisionDocument,
                 completion: @escaping (Result<[String: Extraction]>) -> Void) {
        print("🔎 Started document analysis with size \(Double(document.data.count) / 1024.0)")
        
        cancelAnalysis()
        isAnalyzing = true
        cancellationTokenSource = BFCancellationTokenSource()
        let cancelationToken = cancellationTokenSource?.token
        
        let fileName = "fileName"
        let startDate = Date()
        
        create(document: document, cancelationToken: cancelationToken!, fileName: fileName) { [weak self] response in
            guard let `self` = self else { return }
            let task: BFTask<AnyObject>
            
            switch response {
            case .success(let document):
                task = document.getExtractionsWith(cancelationToken)
            case .failure(let error):
                if let error = error as? AnalysisError, error == .cancelled {
                    task = BFTask.cancelled()
                } else {
                    task = BFTask(error: error)
                }
            }
            
            task.continueWith(block: self.handleAnalysisResults(startDate: startDate,
                                                                completion: completion))
        }
        
    }
    
    func create(document: GiniVisionDocument,
                cancelationToken token: BFCancellationToken,
                fileName: String,
                docType: String,
                completion: @escaping ((Result<GINIDocument>) -> Void)) {
        _ = giniSDK?.sessionManager.getSession()
            .continueWith(block: getSessionBlock(cancelationToken: token))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK?.documentTaskManager.createDocument(withFilename: fileName,
                                                                         from: document.data,
                                                                         docType: docType,
                                                                         cancellationToken: token)
            }).continueWith(block: { task in
                if let document = task.result as? GINIDocument {
                    self.document = document
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
    
    fileprivate func handleAnalysisResults(startDate: Date,
                                           completion: @escaping (Result<[String: Extraction]>) -> Void)
        -> ((BFTask<AnyObject>) -> Any?) {
            return { [weak self] task in
                guard let `self` = self else { return nil }
                
                let elapsedTime = Date().timeIntervalSince(startDate)
                if task.isCancelled {
                    print("❌ Cancelled analysis process after", elapsedTime, "seconds")
                    completion(.failure(AnalysisError.documentCreation))
                    
                    return BFTask<AnyObject>.cancelled()
                }
                
                let finishedString = "Finished analysis process in \(elapsedTime) seconds with"
                
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
