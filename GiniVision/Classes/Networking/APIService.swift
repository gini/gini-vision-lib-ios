//
//  DocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

let GINIAnalysisManagerDidReceiveResultNotification = "GINIAnalysisManagerDidReceiveResultNotification"
let GINIAnalysisManagerDidReceiveErrorNotification  = "GINIAnalysisManagerDidReceiveErrorNotification"
let GINIAnalysisManagerResultDictionaryUserInfoKey  = "GINIAnalysisManagerResultDictionaryUserInfoKey"
let GINIAnalysisManagerErrorUserInfoKey             = "GINIAnalysisManagerErrorUserInfoKey"
let GINIAnalysisManagerDocumentUserInfoKey          = "GINIAnalysisManagerDocumentUserInfoKey"

public typealias Extraction = GINIExtraction
typealias DocumentAnalysisCompletion = (([String: Extraction]?, GINIDocument?, Error?) -> Void)

protocol APIServiceProtocol: class {
    
    var error: Error? { get }
    var isAnalyzing: Bool { get }
    var result: [String: Extraction]? { get }
    
    func analyze(document: GiniVisionDocument,
                 cancelationToken token: CancelationToken,
                 completion: DocumentAnalysisCompletion?)
    func cancelAnalysis()
    func sendFeedback(withResults results: [String: Extraction])
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
                 completion: DocumentAnalysisCompletion?) {
        print("🔎 Started document analysis with size \(Double(document.data.count) / 1024.0)")
        
        cancelAnalysis()
        cancelationToken = token
        isAnalyzing = true
        
        let manager = giniSDK?.documentTaskManager
        let fileName = "fileName"
        var documentId: String?
        let startDate = Date()
        
        _ = giniSDK?.sessionManager.getSession()
            .continue(getSessionBlock(cancelationToken: token))
            .continue(successBlock: { _ in
                if token.cancelled {
                    return BFTask.cancelled()
                }
                return manager?.createDocument(withFilename: fileName, from: document.data, docType: "")
            })
            .continue(successBlock: { (task: BFTask?) in
                if token.cancelled {
                    return BFTask.cancelled()
                }
                
                if let document = task?.result as? GINIDocument {
                    documentId = document.documentId
                    self.document = document
                    print("📄 Created document with id: \(documentId!)")
                    return self.poll(document: document, manager: manager, cancelationToken: token)
                } else {
                    print("Error creating document")
                    return BFTask(error: AnalysisError.documentCreation)
                }
            })
            .continue(handleAnalysisResultsBlock(cancelationToken: token, startDate: startDate, completion: completion))
            .continue({ _ in
                self.isAnalyzing = false
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
    
    fileprivate func handleAnalysisResultsBlock(cancelationToken token: CancelationToken,
                                                startDate: Date,
                                                completion: DocumentAnalysisCompletion?) -> BFContinuationBlock? {
        return { [weak self] (task: BFTask?) in
            guard let `self` = self else { return nil }
            if token.cancelled || (task?.isCancelled == true) {
                print("❌ Canceled analysis process")
                completion?(nil, nil, AnalysisError.documentCreation)
                
                return BFTask.cancelled()
            }
            
            let finishedString = "✅ Finished analysis process in \(Date().timeIntervalSince(startDate)) seconds with"
            
            if let error = task?.error {
                self.error = error
                print(finishedString, "this error: \(error)")
                
                completion?(nil, nil, error)
            } else if let document = self.document,
                let result = task?.result as? [String: Extraction] {
                self.result = result
                self.document = document
                print(finishedString, "no errors")
                
                completion?(result, document, nil)
            } else {
                let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                self.error = error
                print(finishedString, "this error: \(error)")
                
                completion?(nil, nil, AnalysisError.unknown)
                return nil
            }
            
            return nil
        }
    }
    
    fileprivate func poll(document: GINIDocument,
                          manager: GINIDocumentTaskManager?,
                          pollDelay: Int32 = 1000,
                          cancelationToken token: CancelationToken) -> BFTask! {
        print("🕐 Document status pending: ", document.state == .pending)
        if document.state != .pending {
            print("🗂 Getting extractions... ")

            return document.extractions
        } else {
            print("🔄 Polling document status...")

            return self.giniSDK?.apiManager
                .getDocument(document.documentId)
                .continue(successBlock: {[weak manager] task in
                    if let responseDict = task?.result as? [AnyHashable: Any],
                        let newDocument = GINIDocument(fromAPIResponse: responseDict,
                                                       withDocumentManager: manager) {
                        if token.cancelled {
                            return BFTask.cancelled()
                        }
                        let delay = newDocument.state == .pending ? pollDelay : 0
                        
                        return BFTask(delay: delay).continue(successBlock: { _ in
                            return self.poll(document: newDocument, manager: manager, cancelationToken: token)
                        })
                    }
                    return BFTask.cancelled()
                })
        }
    }
    
}
