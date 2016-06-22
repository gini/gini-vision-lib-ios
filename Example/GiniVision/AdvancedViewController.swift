//
//  AdvancedViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class AdvancedViewController: UIViewController {
    
    // Container attributes
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    // Output
    var imageData: NSData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentController = GINICameraViewController(success:
            { imageData in
                self.imageData = imageData
                dispatch_async(dispatch_get_main_queue(), { 
                    self.performSegueWithIdentifier("giniShowReview", sender: self)
                })
            }, failure: { error in
                print(error.localizedDescription)
            })
        
        displayContent(contentController)
    }
    
    override func viewDidAppear(animated: Bool) {
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        GINIVision.setConfiguration(giniConfiguration)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "giniShowReview" {
            if let imageData = imageData,
                let vc = (segue.destinationViewController as? UINavigationController)?.topViewController as? AdvancedReviewViewController {
                vc.imageData = imageData
            }
        }
    }
    
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }

}

