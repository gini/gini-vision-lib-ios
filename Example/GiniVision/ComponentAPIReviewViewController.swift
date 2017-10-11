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
    func didReview(documentReviewed:GiniVisionDocument)
    func didCancelReview()
}


/**
 View controller showing how to implement the review screen using the Component API of the Gini Vision Library for iOS and
 how to process the previously captured image using the Gini SDK for iOS
 */
class ComponentAPIReviewViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    var delegate: ComponentAPIReviewScreenDelegate?
    
    /**
     The image data of the captured document to be reviewed.
     */
    var document: GiniVisionDocument?
    
    fileprivate var originalDocument: GiniVisionDocument?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let document = document else { return }
        originalDocument = document
        
        /*************************************************************************
         * REVIEW SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         *************************************************************************/

        
        // 1. Create the review view controller
        contentController = ReviewViewController(document, successBlock:
            { [unowned self] document in
                print("Component API review view controller received image data")
                // Update current image data when image is rotated by user
                self.document = document

            }, failureBlock: { error in
                print("Component API review view controller received error:\n\(error)")
            })
        
        // 2. Display the review view controller
        displayContent(contentController)
        
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        // Cancel analysis process to avoid unnecessary network calls.
        if parent == nil {
//            delegate?.didCancelReview()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParentViewController || isBeingDismissed {
            delegate?.didCancelReview()
        }
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
        if let document = document {
            delegate?.didReview(documentReviewed: document)
        }
    }
}

