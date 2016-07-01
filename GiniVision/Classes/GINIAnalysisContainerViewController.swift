//
//  GINIAnalysisContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class GINIAnalysisContainerViewController: UIViewController, GINIContainer {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User interface
    private var backButton     = UIBarButtonItem()
    
    // Images
    private var backButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationAnalysisBack")
    }
    
    init(imageData: NSData) {
        super.init(nibName: nil, bundle: nil)
        
        // Configure content controller
        contentController = GINIAnalysisViewController(imageData)
        
        // Configure title
        title = GINIConfiguration.sharedConfiguration.navigationBarAnalysisTitle
        
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        backButton = UIBarButtonItem(image: backButtonImage, style: .Plain, target: self, action: #selector(back))
        backButton.title = GINIConfiguration.sharedConfiguration.navigationBarAnalysisTitleBackButton
        if let s = backButton.title where !s.isEmpty {
            backButton.image = nil
        } else {
            // Set title `nil` because an empty string will cause problems in UI
            backButton.title = nil
        }
        
        // Configure view hierachy
        view.addSubview(containerView)
        navigationItem.setLeftBarButtonItem(backButton, animated: false)
        
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
        
        // Start loading animation
        (contentController as? GINIAnalysisViewController)?.showAnimation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate = (navigationController as? GININavigationViewController)?.giniDelegate
        delegate?.didShowAnalysis?(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        let delegate = (navigationController as? GININavigationViewController)?.giniDelegate
        delegate?.didCancelAnalysis?()
        navigationController?.popViewControllerAnimated(true)
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

extension GINIAnalysisContainerViewController: GINIAnalysisDelegate {
    
    func displayError(withMessage message: String?, andAction action: GININoticeAction?) {
        print("Client wants to display error with message: \(message ?? "no message")")
        action?()
        // TODO: Implement with custom GININotice class
    }
    
}
