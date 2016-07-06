//
//  EasyViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class EasyViewController: UIViewController, GINIVisionDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func easyLaunchGiniVision(sender: AnyObject) {
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.navigationBarItemTintColor = UIColor.whiteColor()
        /* Uncomment block to set custom onboarding screens */
        /*
        if let page1 = storyboard?.instantiateViewControllerWithIdentifier("Onboarding1").view,
           let page2 = storyboard?.instantiateViewControllerWithIdentifier("Onboarding2").view {
            let pages = [ page1, page2 ]
            giniConfiguration.onboardingPages = pages
        }
        */
        presentViewController(GINIVision.viewController(withDelegate: self, withConfiguration: giniConfiguration), animated: true, completion: nil)
    }
    
    func didCapture(imageData: NSData) {
        print("Easy example received image data")
    }
    
    func didReview(imageData: NSData, withChanges changes: Bool) {
        let changesString = changes ? "changes" : "no changes"
        print("Easy example received updated image data with \(changesString)")
    }
    
    func didShowAnalysis(analysisDelegate: GINIAnalysisDelegate) {
        analysisDelegate.displayError(withMessage: "My network error", andAction: { print("Try again") })
    }
    
    func didCancelCapturing() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

