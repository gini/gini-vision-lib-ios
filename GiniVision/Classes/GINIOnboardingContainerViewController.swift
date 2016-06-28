//
//  GINIOnboardingContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Container class for `GINIOnboardingViewController`.
 
 - note: Should be embeded in navigation controller.
 */
internal class GINIOnboardingContainerViewController: UIViewController, GINIContainer {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User Interface
    private var pageControl = UIPageControl()
    private var continueButton = UIBarButtonItem()
    
    // Images
    private var continueButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationOnboardingContinue")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // Configure content controller
        let pages = GINIConfiguration.sharedConfiguration.onboardingPages
        contentController = GINIOnboardingViewController(pages: pages,
                                                         scrollViewDelegate: self)
        
        // Configure title
        title = GINIConfiguration.sharedConfiguration.navigationBarOnboardingTitle
        
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor
        
        // Configure page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count + 1 // Take in account that there will be an "empty" page at the end
        pageControl.currentPageIndicatorTintColor = GINIConfiguration.sharedConfiguration.onboardingCurrentPageIndicatorColor
        pageControl.pageIndicatorTintColor = GINIConfiguration.sharedConfiguration.onboardingPageIndicatorColor
        
        // Configure continue button
        continueButton = UIBarButtonItem(image: continueButtonImage, style: .Plain, target: self, action: #selector(nextPage))
        continueButton.title = GINIConfiguration.sharedConfiguration.navigationBarOnboardingTitleContinueButton
        if let s = continueButton.title where !s.isEmpty {
            continueButton.image = nil
        } else {
            // Set title `nil` because an empty string will cause problems in UI
            continueButton.title = nil
        }
        
        // Configure view hierachy
        view.addSubview(containerView)
        view.addSubview(pageControl)
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
        // TODO: Implement
    }
    
    @IBAction func nextPage() {
        // TODO: Implement
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view

        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Width, relatedBy: .Equal, toItem: containerView, attribute: .Height, multiplier: 3/4, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Width, relatedBy: .Equal, toItem: superview, attribute: .Width, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: superview, attribute: .Width, multiplier: 1, constant: 0, priority: 999)
        UIViewController.addActiveConstraint(item: containerView, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: 0)
        
        // Page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: pageControl, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: pageControl, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: 0)
    }
    
}


extension GINIOnboardingContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // TODO:
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // TODO:
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // TODO:
    }
    
    private func setPageControl(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let contentOffsetX = scrollView.contentOffset.x
        let currentPage = contentOffsetX / pageWidth
        pageControl.currentPage = Int(currentPage)
        
        // Dismiss onboarding on reach of end
        if contentOffsetX + pageWidth >= scrollView.contentSize.width {
            // TODO: Send dismiss wish
        }
    }
    
}
