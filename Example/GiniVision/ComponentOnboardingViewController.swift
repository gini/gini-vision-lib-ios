//
//  ComponentOnboardingViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 06/07/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class ComponentOnboardingViewController: UIViewController {
    
    // Container attributes
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let page1 = storyboard?.instantiateViewControllerWithIdentifier("Onboarding1").view,
              let page2 = storyboard?.instantiateViewControllerWithIdentifier("Onboarding2").view else { return }
        let pages = [ page1, page2 ]
        contentController = GINIOnboardingViewController(pages: pages, scrollViewDelegate: self)
        
        displayContent(contentController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
}

extension ComponentOnboardingViewController: UIScrollViewDelegate {
    
}

