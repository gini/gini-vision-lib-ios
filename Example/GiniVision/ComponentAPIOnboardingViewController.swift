//
//  ComponentAPIOnboardingViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 06/07/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class ComponentAPIOnboardingViewController: UIViewController {
    
    // Container attributes
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the onboarding view controller
        contentController = GINIOnboardingViewController(scrollViewDelegate: nil)
        
        // Display the onboarding view controller
        displayContent(contentController)
    }
    
    // Scrolls the onboarding view controller to the next page
    @IBAction func nextPage(sender: AnyObject) {
        (contentController as? GINIOnboardingViewController)?.scrollToNextPage(true)
    }
    
    // Displays the content controller inside the container view
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
}
