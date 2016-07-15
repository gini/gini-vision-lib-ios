//
//  ComponentAPIReviewViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class ComponentAPIReviewViewController: UIViewController {
    
    // Container attributes
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    // Input
    var imageData: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the review view controller
        contentController = GINIReviewViewController(imageData, success:
            { imageData in
                print("Component API review view controller received image data.")
            }, failure: { error in
                print("Component API review view controller received error:\n\(error)")
            })
        
        // Display the review view controller
        displayContent(contentController)
    }
    
    // Pops back to the camera view controller
    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "giniShowAnalysis" {
            if let vc = segue.destinationViewController as? ComponentAPIAnalysisViewController {
                // Set image data as input for the review view controller
                vc.imageData = imageData
            }
        }
    }
    
    // Displays the content controller inside the container view
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
}

