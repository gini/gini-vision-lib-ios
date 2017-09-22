//
//  ResultTableViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import Gini_iOS_SDK

/**
 Presents a dictionary of results from the analysis process in a table view.
 Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
class ResultTableViewController: UITableViewController {
    
    /**
     The result dictionary from the analysis process.
     */
    var result: GINIResult!
    
    /**
     The document the results have been extracted from.
     Can be used for further processing.
     */
    var document: GINIDocument!
    
    fileprivate var sortedKeys: [String] {
        return Array(result.keys).sorted(by: <)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If a valid document is set, send feedback on it.
        // This is just to show case how to give feedback using the Gini SDK for iOS.
        // In a real world application feedback should be triggered after the user has evaluated and eventually corrected the extractions.
        sendFeedback(forDocument: document)
    }
        
    func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func sendFeedback(forDocument document: GINIDocument) {
        
        /*******************************************
         * SEND FEEDBACK WITH THE GINI SDK FOR IOS *
         *******************************************/
        
        // Get current Gini SDK instance to upload image and process exctraction.
        let sdk = (UIApplication.shared.delegate as! AppDelegate).giniSDK
        
        // 1. Get session
        _ = sdk?.sessionManager.getSession().continue({ (task: BFTask?) -> Any? in
            if (task?.error != nil) {
                return sdk?.sessionManager.logIn()
            }
            return task?.result
            
        // 2. Get extractions from the document
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
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
            let bic = extractions["bic"] as? GINIExtraction ?? GINIExtraction(name: "bic", value: "", entity: "bic", box: nil)!
            bic.value = bicValue
            extractions["bic"] = bic
            // Repeat this step for all altered fields.
            
            // Get the document task manager and send feedback by updating the document.
            let documentTaskManager = sdk?.documentTaskManager
            return documentTaskManager?.update(document)
            
        // 4. Check if feedback was send successfully (only for testing purposes)
        }).continue(successBlock: { (task: BFTask?) -> AnyObject! in
            return document.extractions
            
        // 5. Handle results
        }).continue({ (task: BFTask?) -> AnyObject! in
            if task?.error != nil {
                print("Error sending feedback for document with id: \(document.documentId)")
                return nil
            }
            
            let resultString = (task?.result as? GINIResult)?.description ?? "n/a"
            print("Updated extractions:\n\(resultString)")
            return nil
        })
    }
}

extension ResultTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedKeys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        let key = sortedKeys[indexPath.row]
        cell.textLabel?.text = result[key]?.value
        cell.detailTextLabel?.text = key
        return cell
    }
}
