//
//  GINIReviewContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 20/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class GINIReviewContainerViewController: UIViewController, GINIContainer {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User interface
    private var backButton     = UIBarButtonItem()
    private var continueButton = UIBarButtonItem()

    // Images
    private var backButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationReviewBack")
    }
    private var continueButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationReviewContinue")
    }
    
    // Output
    private var imageData: NSData?
    private var changes = false
    
    init(imageData: NSData) {
        super.init(nibName: nil, bundle: nil)
        
        self.imageData = imageData
        
        // Configure content controller and update image data on success
        contentController = GINIReviewViewController(imageData, success:
            { imageData in
                self.imageData = imageData
                self.changes = true
            }, failure: { error in
                print(error)
            })
        
        // Configure title
        title = GINIConfiguration.sharedConfiguration.navigationBarReviewTitle
        
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor
        
        // Configure back button
        backButton = GINIBarButtonItem(
            image: backButtonImage,
            title: GINIConfiguration.sharedConfiguration.navigationBarReviewTitleBackButton,
            style: .Plain,
            target: self,
            action: #selector(back)
        )
        
        // Configure continue button
        continueButton = GINIBarButtonItem(
            image: continueButtonImage,
            title: GINIConfiguration.sharedConfiguration.navigationBarReviewTitleContinueButton,
            style: .Plain,
            target: self,
            action: #selector(analyse)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        navigationItem.setLeftBarButtonItem(backButton, animated: false)
        navigationItem.setRightBarButtonItem(continueButton, animated: false)
        
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
    
    @IBAction func back() {
        let delegate = (navigationController as? GININavigationViewController)?.giniDelegate
        delegate?.didCancelReview?()
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func analyse() {
        let delegate = (self.navigationController as? GININavigationViewController)?.giniDelegate
        delegate?.didReview(imageData!, withChanges: changes)
        
        // Push analysis container view controller
        navigationController?.pushViewController(GINIAnalysisContainerViewController(imageData: imageData!), animated: true)
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
    }
    
}
