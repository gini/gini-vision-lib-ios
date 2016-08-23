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
     Whether a analysis process is in progress.
     */
    var isAnalyzing = false
    
    private var cancelationToken: CancelationToken?
    
    /**
     Cancels all running analysis processes manually.
     */
    func cancelAnalysis() {
        cancelationToken?.cancel()
        result = nil
        document = nil
        isAnalyzing = false
    }
    
    /**
     Analyzes the given image data returning possible extraction values.
     
     - note: Only one analysis process can be running at a time.
     
     - parameter data:             The image data to be analyzed.
     - parameter cancelationToken: The cancelation token.
     - parameter completion:       The completion block handling the result.
     */
    func analyzeDocument(withImageData data: NSData,
                         cancelationToken token: CancelationToken,
                         completion: ((inner: () throws -> (GINIResult?, GINIDocument?)) -> ())?) {
        
        // Cancel any running analysis process and set cancelation token.
        cancelAnalysis()
        cancelationToken = token
        
        isAnalyzing = true
        
        /**********************************************
         * ANALYZE DOCUMENT WITH THE GINI SDK FOR IOS *
         **********************************************/
        
        print("Started analysis process")
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = (UIApplication.sharedApplication().delegate as! AppDelegate).giniSDK
        
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
        sdk?.sessionManager.getSession().continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if token.cancelled {
                return BFTask.cancelledTask()
            }
            if task.error != nil {
                return sdk?.sessionManager.logIn()
            }
            return task.result
            
        // 2. Create a document from the given image data
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            if token.cancelled {
                return BFTask.cancelledTask()
            }
            return manager?.createDocumentWithFilename(fileName, fromData: data, docType: "")
            
        // 3. Get extractions from the document
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            if token.cancelled {
                return BFTask.cancelledTask()
            }
            
            if let document = task.result as? GINIDocument {
                documentId = document.documentId
                self.document = document
                print("Created document with id: \(documentId!)")
            } else {
                print("Error creating document")
            }
            
            return self.document?.extractions
            
        // 4. Handle results
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if token.cancelled || task.cancelled {
                print("Canceled analysis process")
                return BFTask.cancelledTask()
            }
            
            print("Finished analysis process")
            
            let userInfo: [NSObject: AnyObject]
            let notificationName: String
            
            if let error = task.error {
                userInfo = [ GINIAnalysisManagerErrorUserInfoKey: error ]
                notificationName = GINIAnalysisManagerDidReceiveErrorNotification
                completion?(inner: { _ in throw error })
            } else if let document = self.document,
                      let result = task.result as? GINIResult {
                self.result = result
                self.document = document
                userInfo = [
                    GINIAnalysisManagerResultDictionaryUserInfoKey: result,
                    GINIAnalysisManagerDocumentUserInfoKey: document
                ]
                notificationName = GINIAnalysisManagerDidReceiveErrorNotification
                completion?(inner: { _ in return (result, document) })
            } else {
                enum AnalysisError: ErrorType {
                    case Unknown
                }
                let error = NSError(domain: "net.gini.error.", code: AnalysisError.Unknown._code, userInfo: nil)
                userInfo = [ GINIAnalysisManagerErrorUserInfoKey: error ]
                notificationName = GINIAnalysisManagerDidReceiveErrorNotification
                completion?(inner: { _ in throw AnalysisError.Unknown })
                return nil
            }
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: self, userInfo: userInfo)
            })
            
            return nil
            
        // 5. Finish process
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            self.isAnalyzing = false
            return nil
        })
    }
    
}

