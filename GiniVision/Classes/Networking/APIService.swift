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

typealias GINIResult = [String: GINIExtraction]
typealias DocumentAnalysisCompletion = ((GINIResult?, GINIDocument?, Error?) -> Void)

/**
 Provides a manager class to show how to get extractions from a document image using the Gini SDK for iOS.
 */
final class APIService {
    
    /**
     GiniSDK property to have global access to the Gini API.
     */
    
    var giniSDK: GiniSDK?
    
    /**
     Most current result dictionary from analysis.
     */
    var result: GINIResult?
    
    /**
     Most current analyzed document.
     */
    var document: GINIDocument?
    
    /**
     Most current error that occured during analysis.
     */
    var error: Error?
    
    /**
     Whether a analysis process is in progress.
     */
    var isAnalyzing = false
    
    fileprivate var cancelationToken: CancelationToken?
    enum AnalysisError: Error {
        case documentCreation
        case unknown
    }
    
    /**
     Cancels all running analysis processes manually.
     */
    func cancelAnalysis() {
        cancelationToken?.cancel()
        result = nil
        document = nil
        error = nil
        isAnalyzing = false
    }
    
    init(client: Client) {
        // Set up GiniSDK with your credentials.
        let builder = GINISDKBuilder.anonymousUser(withClientID: client.clientId,
                                                   clientSecret: client.clientSecret,
                                                   userEmailDomain: client.clientEmailDomain)
        self.giniSDK = builder?.build()        
    }
    
    /**
     Analyzes the given image data returning possible extraction values.
     
     - note: Only one analysis process can be running at a time.
     
     - parameter data:             The image data to be analyzed.
     - parameter cancelationToken: The cancelation token.
     - parameter completion:       The completion block handling the result.
     */
    // swiftlint:disable function_body_length
    func analyzeDocument(withData data: Data,
                         cancelationToken token: CancelationToken,
                         completion: DocumentAnalysisCompletion?) {
        
        // Cancel any running analysis process and set cancelation token.
        cancelAnalysis()
        cancelationToken = token
        
        isAnalyzing = true
        
        /**********************************************
         * ANALYZE DOCUMENT WITH THE GINI SDK FOR IOS *
         **********************************************/
        
        print("🔎 Started document analysis with size \(Double(data.count) / 1024.0)")
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = giniSDK
        
        // Create a document task manager to handle document tasks on the Gini API.
        let manager = sdk?.documentTaskManager
        
        // Create a file name for the document.
        let fileName = "your_filename"
        
        var documentId: String?
        
        // Return early when process was canceled.
        if token.cancelled {
            return
        }
        
        // 1. Get session
        _ = sdk?.sessionManager.getSession().continue({ (task: BFTask?) -> Any! in
            if token.cancelled {
                return BFTask.cancelled()
            }
            if task?.error != nil {
                return sdk?.sessionManager.logIn()
            }
            return task?.result
            
            // 2. Create a document from the given image data
        }).continue(successBlock: { _ -> AnyObject! in
            if token.cancelled {
                return BFTask.cancelled()
            }
            return manager?.createDocument(withFilename: fileName, from: data, docType: "")
            
            // 3. Get extractions from the document
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
            if token.cancelled {
                return BFTask.cancelled()
            }
            
            if let document = task?.result as? GINIDocument {
                documentId = document.documentId
                self.document = document
                print("📄 Created document with id: \(documentId!)")
                return self.document?.extractions
                
            } else {
                print("Error creating document")
                return BFTask(error: AnalysisError.documentCreation)
            }
            
            // 4. Handle results
        }).continue({ (task: BFTask?) -> AnyObject! in
            if token.cancelled || (task?.isCancelled == true) {
                print("❌ Canceled analysis process")
                completion?(nil, nil, AnalysisError.documentCreation)
                
                return BFTask.cancelled()
            }
            
            if let error = task?.error {
                self.error = error
                print("✅ Finished analysis process with this error: \(error)")
                completion?(nil, nil, error)
            } else if let document = self.document,
                let result = task?.result as? GINIResult {
                self.result = result
                self.document = document
                print("✅ Finished analysis process with no errors")
                completion?(result, document, nil)
            } else {
                let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                self.error = error
                print("✅ Finished analysis process with this error: \(error)")
                completion?(nil, nil, AnalysisError.unknown)
                return nil
            }
            
            return nil
            
            // 5. Finish process
        }).continue({ (_: BFTask?) -> AnyObject! in
            self.isAnalyzing = false
            return nil
        })
    }
    
    /*
     If a valid document is set, send feedback on it.
     This is just to show case how to give feedback using the Gini SDK for iOS.
     In a real world application feedback should be triggered after the user
     has evaluated and eventually corrected the extractions.
     
     - parameter document: Gini document.
     
     */
    func sendFeedback(forDocument document: GINIDocument) {
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = giniSDK
        
        // 1. Get session
        _ = sdk?.sessionManager.getSession().continue({ (task: BFTask?) -> Any? in
            if task?.error != nil {
                return sdk?.sessionManager.logIn()
            }
            return task?.result
            
            // 2. Get extractions from the document
        }).continue(successBlock: { _ -> AnyObject! in
            return document.extractions
            
            // 3. Create and send feedback on the document
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
            
            // Use `NSMutableDictionary` to work with a mutable class type which is passed by reference.
            guard let extractions = task?.result as? NSMutableDictionary else {
                enum FeedbackError: Error {
                    case unknown
                }
                let error = NSError(domain: "net.gini.error.", code: FeedbackError.unknown._code, userInfo: nil)
                return BFTask(error: error)
            }
            
            // As an example will set the BIC value statically.
            // In a real world application the user input should be used as the new value.
            // Feedback should only be send for labels which the user has seen. Unseen labels should be filtered out.
            
            let bicValue = "BYLADEM1001"
            let bic = extractions["bic"] as? GINIExtraction ?? GINIExtraction(name: "bic",
                                                                              value: "",
                                                                              entity: "bic",
                                                                              box: nil)!
            bic.value = bicValue
            extractions["bic"] = bic
            // Repeat this step for all altered fields.
            
            // Get the document task manager and send feedback by updating the document.
            let documentTaskManager = sdk?.documentTaskManager
            return documentTaskManager?.update(document)
            
            // 4. Check if feedback was send successfully (only for testing purposes)
        }).continue(successBlock: { _ -> AnyObject! in
            return document.extractions
            
            // 5. Handle results
        }).continue({ (task: BFTask?) -> AnyObject! in
            if task?.error != nil {
                print("Error sending feedback for document with id: \(document.documentId)")
                return nil
            }
            
            let resultString = (task?.result as? GINIResult)?.description ?? "n/a"
            print("🚀 Feedback sent")
            
            print("\n--------------------------\n📑 Updated extractions:\n-------------------------- \n" +
                "\(resultString)\n--------------------------\n")
            return nil
        })
    }
    
}

