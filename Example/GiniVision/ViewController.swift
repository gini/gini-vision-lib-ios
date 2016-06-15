//
//  ViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright (c) 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Globally set navigation bar appearance
//        UINavigationBar.appearance().barTintColor = UIColor.orangeColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func easyLaunchGiniVision(sender: AnyObject) {
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        presentViewController(GINIVision.viewController(withConfiguration: giniConfiguration), animated: true, completion: nil)
    }
    
}

