//
//  ReviewContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 20/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class ReviewContainerViewController: UIViewController, ContainerViewController {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User interface
    fileprivate var continueButton = UIBarButtonItem()

    // Resources
    fileprivate let continueButtonResources = PreferredButtonResource(image: "navigationReviewContinue", title: "ginivision.navigationbar.review.continue", comment: "Button title in the navigation bar for the continue button on the review screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarReviewTitleContinueButton)
    
    fileprivate lazy var backButtonResources = PreferredButtonResource(image: "navigationReviewBack", title: "ginivision.navigationbar.review.back", comment: "Button title in the navigation bar for the back button on the review screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarReviewTitleBackButton)
    
    fileprivate lazy var closeButtonResources = PreferredButtonResource(image: "navigationCameraClose", title: "ginivision.navigationbar.review.close", comment: "Button title in the navigation bar for the close button on the review screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton)
    
    // Output
    fileprivate var document: GiniVisionDocument?
    fileprivate var changes = false
    
    init(document: GiniVisionDocument) {
        super.init(nibName: nil, bundle: nil)
        
        self.document = document
        
        // Configure content controller and update image data on success
        contentController = ReviewViewController(self.document!, successBlock:
            { [unowned self] document in
                self.document = document
                self.changes = true
       
            }, failureBlock: { error in
                print(error)
            })
        
        // Configure title
        title = GiniConfiguration.sharedConfiguration.navigationBarReviewTitle
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor
        
        // Configure continue button
        continueButton = GiniBarButtonItem(
            image: continueButtonResources.preferredImage,
            title: continueButtonResources.preferredText,
            style: .plain,
            target: self,
            action: #selector(analyse)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        
        navigationItem.setRightBarButton(continueButton, animated: false)
        
        // Add constraints
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add content to container view
        displayContent(contentController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupLeftBarButton()
    }
    
    fileprivate func setupLeftBarButton() {
        guard let navController = navigationController else {
            return
        }
        
        // Configure back button. Needs to be done here because otherwise the navigation controller would be nil
        if navigationItem.leftBarButtonItem == nil {
            setupLeftNavigationItem(usingResources: backButtonPreferredResource(forNavController: navController), selector:#selector(backToCamera))
        }
    }
    
    @IBAction func back() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelReview?()
        
        handleBackPressed()
    }
    
    fileprivate func handleBackPressed() {
        guard let navController = navigationController else {
            return
        }
        
        if self.isFirstViewController(inNavController: navController) {
            navController.dismiss(animated: true, completion: nil)
        } else {
            _ = navController.popViewController(animated: true)
        }
    }
    
    fileprivate func backButtonPreferredResource(forNavController navController:UINavigationController) -> PreferredButtonResource {
        if self.isFirstViewController(inNavController: navController) {
            return closeButtonResources
        }
        return backButtonResources
    }
    
    fileprivate func isFirstViewController(inNavController navController:UINavigationController) -> Bool {
        if navController.viewControllers.count == 1 {
            return true
        }
        return false
    }
    
    @IBAction func analyse() {
        guard let delegate = (self.navigationController as? GiniNavigationViewController)?.giniDelegate, let document = document else { return }
        
        if let didReview = delegate.didReview(document:withChanges:) {
            didReview(document, changes)
        } else if let didReview = delegate.didReview(_:withChanges:){
            didReview(document.data, changes)
        } else {
            fatalError("GiniVisionDelegate.didReview(document: GiniVisionDocument, withChanges changes: Bool) should be implemented")
        }
        
        // Push analysis container view controller
        navigationController?.pushViewController(AnalysisContainerViewController(document: document), animated: true)
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
    }
    
}
