//
//  AnalysisManager.swift
//  GiniVision
//
//  Created by Peter Pult on 10/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//


import UIKit
import Gini_iOS_SDK

class AnalysisManager {
    private var cancelled = false
    
    func cancel() {
        cancelled = true
    }
    
    func analyzeDocument(withImageData data: NSData, completion: (inner: () throws -> [String: GINIExtraction]?) -> ()) {
        /*********************************************
         * UPLOAD DOCUMENT WITH THE GINI SDK FOR IOS *
         *********************************************/
        
        // Get current Gini SDK instance to upload image and process exctraction
        let sdk = (UIApplication.sharedApplication().delegate as! AppDelegate).giniSDK
        
        // Create a document task manager to handle document tasks on the Gini API
        let manager = sdk?.documentTaskManager
        
        // Create a file name for the document
        let fileName = "your_filename";
        
        var giniDocument: GINIDocument?
        var documentId: String?
        
        if cancelled {
            return
        }
        sdk?.sessionManager.getSession().continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if self.cancelled {
                return BFTask.cancelledTask()
            }
            if (task.error != nil) {
                return sdk?.sessionManager.logIn()
            }
            return task.result
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            if self.cancelled {
                return BFTask.cancelledTask()
            }
            return manager?.createDocumentWithFilename(fileName, fromData: data, docType: "")
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            if self.cancelled {
                return BFTask.cancelledTask()
            }
            giniDocument = task.result as? GINIDocument
            documentId = giniDocument?.documentId
            print("documentId: \(documentId)")
            return giniDocument?.extractions
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if self.cancelled || task.cancelled {
                return BFTask.cancelledTask()
            }
            if let error = task.error {
                completion(inner: { _ in throw error })
                return nil
            }
            completion(inner: { _ in return task.result as? [String: GINIExtraction]})
            return nil
        })
    }
    
}

