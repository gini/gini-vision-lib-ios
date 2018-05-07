//
//  ComponentAPIReviewViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

protocol ComponentAPIReviewViewControllerDelegate: class {
    func componentAPIReview(_ viewController: ComponentAPIReviewViewController,
                            didReviewDocument document: GiniVisionDocument)
    func componentAPIReview(_ viewController: ComponentAPIReviewViewController,
                            didRotate document: GiniVisionDocument)
}

/**
 View controller showing how to implement the review screen using
 the Component API of the Gini Vision Library for iOS and
 how to process the previously captured image using the Gini SDK for iOS
 */
final class ComponentAPIReviewViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    weak var delegate: ComponentAPIReviewViewControllerDelegate?
    var document: GiniVisionDocument!
    var giniConfiguration: GiniConfiguration!
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*************************************************************************
         * REVIEW SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         *************************************************************************/
        
        // 1. Create the review view controller
        let reviewViewController = ReviewViewController(document, giniConfiguration: giniConfiguration)
        reviewViewController.delegate = self
        contentController = reviewViewController
        
        // 2. Display the review view controller
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
    @IBAction func showAnalysis(_ sender: AnyObject) {
        delegate?.componentAPIReview(self, didReviewDocument: document)
    }
}

extension ComponentAPIReviewViewController: ReviewViewControllerDelegate {
    func review(_ viewController: ReviewViewController, didReview document: GiniVisionDocument) {
        self.document = document
        self.delegate?.componentAPIReview(self, didRotate: document)
    }
}
