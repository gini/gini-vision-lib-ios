//
//  ScreenAPIViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class ScreenAPIViewController: UIViewController, GINIVisionDelegate {

    @IBAction func easyLaunchGiniVision(sender: AnyObject) {
        
        // Create a custom configuration object
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.navigationBarItemTintColor = UIColor.whiteColor()
        
        // Create the Gini Vision Library view controller and pass in the configuration object
        let vc = GINIVision.viewController(withDelegate: self, withConfiguration: giniConfiguration)
        
        // Present the Gini Vision Library Screen API modally
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // MARK: GINIVisionDelegate
    // Mandatory delegate methods
    func didCapture(imageData: NSData) {
        print("Screen API received image data.")
    }
    
    func didReview(imageData: NSData, withChanges changes: Bool) {
        let changesString = changes ? "changes" : "no changes"
        print("Screen API received updated image data with \(changesString).")
    }
    
    func didCancelCapturing() {
        print("Screen API canceled capturing.")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Optional delegate methods
    func didCancelReview() {
        print("Screen API canceled review.")
    }
    
    func didShowAnalysis(analysisDelegate: GINIAnalysisDelegate) {
        print("Screen API started analysis screen.")
        
        // Display an error with a custom message and custom action on the analysis screen
        analysisDelegate.displayError(withMessage: "My network error", andAction: { print("Try again") })
    }
    
    func didCancelAnalysis() {
        print("Screen API canceled analysis.")
    }
    
}

