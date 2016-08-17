//
//  ScreenAPIViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

class ScreenAPIViewController: UIViewController {
    
    var isUITest: Bool {
        return NSProcessInfo.processInfo().arguments.contains("--UITest")
    }
    
    // MARK: User interaction
    
    /**
     User interaction method to start the Gini Vision Library via the Screen API.
     
     - parameter sender: The button sending the click event.
     */
    @IBAction func easyLaunchGiniVision(sender: AnyObject) {
        
        // Create a custom configuration object
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        
        // Make sure the app always behaves the same when run from UITests
        if isUITest {
            giniConfiguration.onboardingShowAtFirstLaunch = false
        }
        
        // Set navigation bar tint to white because it just looks better that way
        giniConfiguration.navigationBarItemTintColor = UIColor.whiteColor()
        
        // Create the Gini Vision Library view controller and pass in the configuration object
        let vc = GINIVision.viewController(withDelegate: self, withConfiguration: giniConfiguration)
        
        // Present the Gini Vision Library Screen API modally
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // MARK: Handle analysis of document
    var analysisDelegate: GINIAnalysisDelegate?
    var imageData: NSData?
    var analysisManager: AnalysisManager?
    var result: [String: GINIExtraction]? { // TODO: Make this controller independent from Gini iOS SDK
        didSet {
            if result != nil { showResults() }
        }
    }
    var errorMessage: String? {
        didSet {
            if errorMessage != nil { showErrorMessage() }
        }
    }
    
    /**
     Will show an error message on the analysis screen. With a custom action which will be executed when the error message is tapped.
     
     - note: Will only be performed when analysis screen is showing.
     */
    func showErrorMessage() {
        guard let errorMessage = self.errorMessage,
            let imageData = self.imageData else {
                return
        }
        
        // Display an error with a custom message and custom action on the analysis screen
        analysisDelegate?.displayError(withMessage: errorMessage, andAction: {
            self.analyzeDocument(withImageData: imageData)
        })
    }
    
    /**
     Will close the Gini Vision Library and print the results of the document analysis.
     
     - note: Will only be performed when analysis screen is showing.
     */
    func showResults() {
        
        // Show results when on analysis screen
        if let _ = analysisDelegate {
            analysisDelegate = nil
            dispatch_async(dispatch_get_main_queue(), {
                self.dismissViewControllerAnimated(true, completion: {
                    print("FINISHED WITH RESULT\n\(self.result)")
                })
            })
        }
    }
    
    /**
     Will analyze the given image data.
     
     - parameter data: Image data to be analyzed.
     */
    func analyzeDocument(withImageData data: NSData) {
        
        // Do not perform network tasks when UI testing.
        if isUITest {
            return
        }
        
        cancelAnalsyis()
        imageData = data
        analysisManager = AnalysisManager()
        analysisManager?.analyzeDocument(withImageData: data, completion: { inner in
            do {
                guard let result = try inner() else {
                    return self.errorMessage = "Ein unbekannter Fehler ist aufgetreten. Wiederholen"
                }
                self.result = result
                
            } catch _ {
                self.errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
            }
        })
    }
    
    /**
     Cancels any ongoing analysis process and resets according paramters.
     */
    func cancelAnalsyis() {
        analysisManager?.cancel()
        analysisManager = nil
        result = nil
        errorMessage = nil
        imageData = nil
    }
    
}

extension ScreenAPIViewController: GINIVisionDelegate {
    
    // Mandatory delegate methods
    func didCapture(imageData: NSData) {
        
        // Send original image data to analysis to have the results in as early as possible
        analyzeDocument(withImageData: imageData)
    }
    
    func didReview(imageData: NSData, withChanges changes: Bool) {
        
        // Changes were made to the document so the new data needs to be analyzed
        if changes {
            analyzeDocument(withImageData: imageData)
            return
        }
        
        // No changes were made and their is already a result from the original data - Great!
        if let result = result {
            dismissViewControllerAnimated(true, completion: {
                print("FINISHED WITH RESULT\n\(result)")
            })
        }
    }
    
    func didCancelCapturing() {
        print("Screen API canceled capturing.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Optional delegate methods
    func didCancelReview() {
        
        // Cancel analysis process to avoid unnecessary network calls
        cancelAnalsyis()
    }
    
    func didShowAnalysis(analysisDelegate: GINIAnalysisDelegate) {
        self.analysisDelegate = analysisDelegate
        
        // Show error message which may already occured while document was still reviewed
        showErrorMessage()
        
        // Send test error message when UI testing
        if isUITest {
            analysisDelegate.displayError(withMessage: "My network error", andAction: { print("Try again") })
        }
    }
    
    func didCancelAnalysis() {
        
        // Cancel analysis process to avoid unnecessary network calls
        cancelAnalsyis()
        
        // Reset analysis delegate
        analysisDelegate = nil
    }
    
}