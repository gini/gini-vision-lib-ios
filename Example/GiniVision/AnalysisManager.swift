//
//  AnalysisManager.swift
//  GiniVision
//
//  Created by Peter Pult on 10/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//


import UIKit
import Gini_iOS_SDK

let GINIAnalysisManagerDidReceiveResultNotification = "GINIAnalysisManagerDidReceiveResultNotification"
let GINIAnalysisManagerDidReceiveErrorNotification  = "GINIAnalysisManagerDidReceiveErrorNotification"
let GINIAnalysisManagerResultDictionaryUserInfoKey  = "GINIAnalysisManagerResultDictionaryUserInfoKey"
let GINIAnalysisManagerErrorUserInfoKey             = "GINIAnalysisManagerErrorUserInfoKey"
let GINIAnalysisManagerDocumentUserInfoKey          = "GINIAnalysisManagerDocumentUserInfoKey"

typealias GINIResult = [String: GINIExtraction]
/**
 Provides a manager class to show how to get extractions from a document image using the Gini SDK for iOS.
 */
class AnalysisManager {
    
    /**
     Singleton method returning an instance of the analysis manager.
     */
    static let sharedManager = AnalysisManager()
    
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
    
    /**
     Analyzes the given image data returning possible extraction values.
     
     - note: Only one analysis process can be running at a time.
     
     - parameter data:             The image data to be analyzed.
     - parameter cancelationToken: The cancelation token.
     - parameter completion:       The completion block handling the result.
     */
    func analyzeDocument(withImageData data: Data,
                         cancelationToken token: CancelationToken,
                         completion: ((_ inner: (() throws -> (GINIResult?, GINIDocument?))?) -> ())?) {
        
        // Cancel any running analysis process and set cancelation token.
        cancelAnalysis()
        cancelationToken = token
        
        isAnalyzing = true
        
        /**********************************************
         * ANALYZE DOCUMENT WITH THE GINI SDK FOR IOS *
         **********************************************/
        
        print("Started analysis process")
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = (UIApplication.shared.delegate as! AppDelegate).giniSDK
        
        // Create a document task manager to handle document tasks on the Gini API.
        let manager = sdk?.documentTaskManager
        
        // Create a file name for the document.
        let fileName = "your_filename";
        
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
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
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
                print("Created document with id: \(documentId!)")
            } else {
                print("Error creating document")
            }
            
            return self.document?.extractions
            
        // 4. Handle results
        }).continue({ (task: BFTask?) -> AnyObject! in
            if token.cancelled || (task?.isCancelled == true) {
                print("Canceled analysis process")
                return BFTask.cancelled()
            }
            
            print("Finished analysis process")
            
            let userInfo: [AnyHashable: Any]
            let notificationName: String
            
            if let error = task?.error {
                self.error = error
                userInfo = [ GINIAnalysisManagerErrorUserInfoKey: error ]
                notificationName = GINIAnalysisManagerDidReceiveErrorNotification
                completion?({ _ in throw error })
            } else if let document = self.document,
                      let result = task?.result as? GINIResult {
                self.result = result
                self.document = document
                userInfo = [
                    GINIAnalysisManagerResultDictionaryUserInfoKey: result,
                    GINIAnalysisManagerDocumentUserInfoKey: document
                ]
                notificationName = GINIAnalysisManagerDidReceiveResultNotification
                completion?({ _ in return (result, document) })
            } else {
                enum AnalysisError: Error {
                    case unknown
                }
                let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                self.error = error
                userInfo = [ GINIAnalysisManagerErrorUserInfoKey: error ]
                notificationName = GINIAnalysisManagerDidReceiveErrorNotification
                completion?({ _ in throw AnalysisError.unknown })
                return nil
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: self, userInfo: userInfo)
            }
            
            return nil
            
        // 5. Finish process
        }).continue({ (_: BFTask?) -> AnyObject! in
            self.isAnalyzing = false
            return nil
        })
    }
    
}

