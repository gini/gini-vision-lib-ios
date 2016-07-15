//
//  GINIOnboardingContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Block which will be executed when the onboarding was dismissed.
 */
internal typealias GINIOnboardingContainerCompletionBlock = () -> ()

/**
 Container class for `GINIOnboardingViewController`.
 
 - note: Should be embedded in a navigation controller.
 */
internal class GINIOnboardingContainerViewController: UIViewController, GINIContainer {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User Interface
    private var pageControlContainerView = UIView()
    private var pageControl              = UIPageControl()
    private var continueButton           = UIBarButtonItem()
    private let backgroundAlpha: CGFloat = 0.85
    
    // Images
    private var continueButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationOnboardingContinue")
    }
    
    // Output
    private var completionBlock: GINIOnboardingContainerCompletionBlock?
    
    init(withCompletion completion: GINIOnboardingContainerCompletionBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        completionBlock = completion
        
        // Configure content controller
        var pages = GINIConfiguration.sharedConfiguration.onboardingPages
        pages.append(UIView()) // Add an empty last page to transition nicely back to camera
        contentController = GINIOnboardingViewController(pages: pages,
                                                         scrollViewDelegate: self)
        
        // Configure title
        title = GINIConfiguration.sharedConfiguration.navigationBarOnboardingTitle
        
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor.colorWithAlphaComponent(backgroundAlpha)
        
        // Configure page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = GINIConfiguration.sharedConfiguration.onboardingCurrentPageIndicatorColor
        pageControl.pageIndicatorTintColor = GINIConfiguration.sharedConfiguration.onboardingPageIndicatorColor
        
        // Configure continue button
        continueButton = GINIBarButtonItem(
            image: continueButtonImage,
            title: GINIConfiguration.sharedConfiguration.navigationBarOnboardingTitleContinueButton,
            style: .Plain,
            target: self,
            action: #selector(nextPage)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        view.addSubview(pageControlContainerView)
        pageControlContainerView.addSubview(pageControl)
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
    
    @IBAction func close() {
        dismissViewControllerAnimated(false, completion: completionBlock)
    }
    
    @IBAction func nextPage() {
        (contentController as? GINIOnboardingViewController)?.scrollToNextPage(true)
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
        
        // Page control container view
        pageControlContainerView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: pageControlContainerView, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: pageControlContainerView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: pageControlContainerView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: pageControlContainerView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: pageControlContainerView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: pageControl, attribute: .Height, multiplier: 1.1, constant: 0)
        
        // Page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: pageControl, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 55)
        UIViewController.addActiveConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: pageControlContainerView, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: pageControl, attribute: .CenterY, relatedBy: .Equal, toItem: pageControlContainerView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
}

extension GINIOnboardingContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        setPageControl(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        setPageControl(scrollView)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Update fixed elements position
        let pageWidth = scrollView.frame.size.width
        let contentOffsetX = scrollView.contentOffset.x
        var frameOffsetX = contentOffsetX - pageWidth * CGFloat(pageControl.numberOfPages - 2)
        let fixedFrame = view.frame
        frameOffsetX = max(-frameOffsetX, -fixedFrame.width)
        frameOffsetX = min(frameOffsetX, 0)
        navigationController?.navigationBar.frame.origin.x = frameOffsetX
        pageControlContainerView.frame.origin.x = frameOffsetX
        
        // Update background alpha
        var alpha = backgroundAlpha
        if contentOffsetX > 0 {
            alpha = min(backgroundAlpha, 1 - fabs(frameOffsetX/fixedFrame.width)) // Lighten the background when overflowing to the right
        } else {
            alpha = max(backgroundAlpha, fabs((contentOffsetX*0.3)/fixedFrame.width) + backgroundAlpha) // Darken the background when overflowing to the left
        }
        view.backgroundColor = view.backgroundColor?.colorWithAlphaComponent(alpha)
    }
    
    private func setPageControl(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let contentOffsetX = scrollView.contentOffset.x
        let currentPage = contentOffsetX / pageWidth
        pageControl.currentPage = Int(currentPage)
        
        // Dismiss onboarding on reach of end
        if contentOffsetX + pageWidth >= scrollView.contentSize.width {
            close()
        }
    }
    
}
