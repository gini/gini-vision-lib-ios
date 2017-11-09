//
//  ComponentAPIHelpViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 06/07/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

/**
 View controller showing how to implement the onboarding screen using the Component API of the Gini Vision Library for iOS.
 */
class ComponentAPIOnboardingViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*****************************************************************************
         * ONBOARDING SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         *****************************************************************************/
        
        // 2. Create the onboarding view controller
        contentController = OnboardingViewController(scrollViewDelegate: nil)
        
        // 3. Display the onboarding view controller
        displayContent(contentController)
    }
    
    // Displays the content controller inside the container view
    func displayContent(_ controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    // MARK: User actions
    @IBAction func nextPage(_ sender: AnyObject) {
        
        // Scroll the onboarding to the next page.
        (contentController as? OnboardingViewController)?.scrollToNextPage(true)
    }
    
}
