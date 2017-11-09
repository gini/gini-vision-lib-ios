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

protocol ComponentAPIReviewScreenDelegate:class {
    func didReview(document:GiniVisionDocument)
    func didRotate(document:GiniVisionDocument)
}

/**
 View controller showing how to implement the review screen using the Component API of the Gini Vision Library for iOS and
 how to process the previously captured image using the Gini SDK for iOS
 */
class ComponentAPIReviewViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    var delegate: ComponentAPIReviewScreenDelegate?
    var document: GiniVisionDocument!
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*************************************************************************
         * REVIEW SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         *************************************************************************/
        
        // 1. Create the review view controller
        contentController = ReviewViewController(document, successBlock:
            { [unowned self] document in
                // Update current image data when image is rotated by user
                self.document = document
                self.delegate?.didRotate(document: document)

            }, failureBlock: { error in
                print("Component API review view controller received error:\n\(error)")
            })
        
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
        delegate?.didReview(document: document)
    }
}

