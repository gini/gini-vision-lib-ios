//
//  ViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class ViewController: UIViewController, GINIVisionDelegate {

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
        presentViewController(GINIVision.viewController(withDelegate: self, withConfiguration: giniConfiguration), animated: true, completion: nil)
    }
    
    func didCapture(imageData: NSData) {
        print("Example App received image data")
    }
    
    func didCancelCapturing() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

