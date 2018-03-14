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
                 cancelationToken token: CancelationToken,
                 completion: @escaping (Result<[String: Extraction]>) -> Void)
    func cancelAnalysis()
    func create(document: GiniVisionDocument,
                cancelationToken token: CancelationToken,
                fileName: String,
                docType: String,
                completion: @escaping ((Result<GINIDocument>) -> Void))
    func sendFeedback(withResults results: [String: Extraction])
}

extension APIServiceProtocol {
    func create(document: GiniVisionDocument,
                cancelationToken token: CancelationToken,
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
    
    fileprivate var cancelationToken: CancelationToken?
    var document: GINIDocument?
    var error: Error?
    var giniSDK: GiniSDK?
    var isAnalyzing = false
    var result: [String: Extraction]?
    
    enum AnalysisError: Error {
        case documentCreation
        case unknown
    }
    
    func cancelAnalysis() {
        cancelationToken?.cancel()
        result = nil
        document = nil
        error = nil
        isAnalyzing = false
    }
    
    init(sdk: GiniSDK?) {
        self.giniSDK = sdk
    }
    
    func analyze(document: GiniVisionDocument,
                 cancelationToken token: CancelationToken,
                 completion: @escaping (Result<[String: Extraction]>) -> Void) {
        print("🔎 Started document analysis with size \(Double(document.data.count) / 1024.0)")
        
        cancelAnalysis()
        cancelationToken = token
        isAnalyzing = true
        
        let fileName = "fileName"
        let startDate = Date()
        
        create(document: document, cancelationToken: token, fileName: fileName) { [weak self] response in
            guard let `self` = self else { return }
            let task: BFTask
            if token.cancelled {
                task = BFTask.cancelled()
            } else {
                switch response {
                case .success(let document):
                    task = document.extractions
                case .failure(let error):
                    task = BFTask(error: error)
                }
                
                task.continue(self.handleAnalysisResults(cancelationToken: token,
                                                              startDate: startDate,
                                                              completion: completion))
            }
        }
        
    }
    
    func create(document: GiniVisionDocument,
                cancelationToken token: CancelationToken,
                fileName: String,
                docType: String,
                completion: @escaping ((Result<GINIDocument>) -> Void)) {
        _ = giniSDK?.sessionManager.getSession()
            .continue(getSessionBlock(cancelationToken: token))
            .continue(successBlock: { [weak self] _ in
                if token.cancelled {
                    return BFTask.cancelled()
                }
                return self?.giniSDK?.documentTaskManager.createDocument(withFilename: fileName,
                                                                         from: document.data,
                                                                         docType: docType)
            }).continue({ task in
                if let document = task?.result as? GINIDocument {
                    self.document = document
                    print("📄 Created document with id: \(document.documentId ?? "")")
                    
                    completion(.success(document))
                } else {
                    completion(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
        
    }
    
    func sendFeedback(withResults results: [String: Extraction]) {
        _ = giniSDK?.sessionManager.getSession()
            .continue(getSessionBlock())
            .continue(successBlock: { _ in return self.document?.extractions })
            .continue(successBlock: { (task: BFTask?) in
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
            .continue(successBlock: { _ in return self.document?.extractions })
            .continue({ (task: BFTask?) in
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
    
    fileprivate func getSessionBlock(cancelationToken token: CancelationToken? = nil) -> BFContinuationBlock? {
        return { [weak self] (task: BFTask?) -> Any! in
            guard let `self` = self else { return nil }
            
            if let token = token, token.cancelled {
                return BFTask.cancelled()
            }
            if task?.error != nil {
                return self.giniSDK?.sessionManager.logIn()
            }
            return task?.result
        }
    }
    
    fileprivate func handleAnalysisResults(cancelationToken token: CancelationToken,
                                           startDate: Date,
                                           completion: @escaping (Result<[String: Extraction]>) -> Void)
        -> BFContinuationBlock? {
            
        return { [weak self] (task: BFTask?) in
            guard let `self` = self else { return nil }
            if token.cancelled || (task?.isCancelled == true) {
                print("❌ Canceled analysis process")
                completion(.failure(AnalysisError.documentCreation))
                
                return BFTask.cancelled()
            }
            
            let finishedString = "✅ Finished analysis process in \(Date().timeIntervalSince(startDate)) seconds with"
            
            if let error = task?.error {
                self.error = error
                print(finishedString, "this error: \(error)")
                
                completion(.failure(error))
            } else if let result = task?.result as? [String: Extraction] {
                self.result = result
                print(finishedString, "no errors")
                
                completion(.success((result)))
            } else {
                let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                self.error = error
                print(finishedString, "this error: \(error)")
                
                completion(.failure(AnalysisError.unknown))
            }
            
            self.isAnalyzing = false
            
            return nil
        }
    }
    
}
