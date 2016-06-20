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
    
    init(imageData: NSData) {
        super.init(nibName: nil, bundle: nil)
        
        // Configure content controller and call delegate method on success
        contentController = GINIReviewViewController(imageData, callback: { imageData in
            guard let imageData = imageData else { return }
            let delegate = (self.navigationController as? GININavigationViewController)?.giniDelegate
            delegate?.didReview(imageData, withChanges: true) // TODO: Implement changes
        })
        
        // Configure title
        title = GINIConfiguration.sharedConfiguration.navigationBarReviewTitle
        
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        backButton = UIBarButtonItem(image: backButtonImage, style: .Plain, target: self, action: #selector(back))
        backButton.title = GINIConfiguration.sharedConfiguration.navigationBarReviewTitleBackButton
        if let s = backButton.title where !s.isEmpty {
            backButton.image = nil
        } else {
            // Set title `nil` because an empty string will cause problems in UI
            backButton.title = nil
        }
        
        // Configure help button
        continueButton = UIBarButtonItem(image: continueButtonImage, style: .Plain, target: self, action: #selector(analyse))
        continueButton.title = GINIConfiguration.sharedConfiguration.navigationBarReviewTitleContinueButton
        if let s = continueButton.title where !s.isEmpty {
            continueButton.image = nil
        } else {
            // Set title `nil` because an empty string will cause problems in UI
            continueButton.title = nil
        }
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        let delegate = (navigationController as? GININavigationViewController)?.giniDelegate
        delegate?.didCancelReview?()
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func analyse() {
        // TODO: Implement call
        print("GiniVision: Wants to analyse reviewed image")
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
