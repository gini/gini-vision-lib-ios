//
//  OnboardingContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Block which will be executed when the onboarding was dismissed.
 */
internal typealias OnboardingContainerCompletionBlock = () -> ()

/**
 Container class for `OnboardingViewController`.
 
 - note: Should be embedded in a navigation controller.
 */
internal class OnboardingContainerViewController: UIViewController, ContainerViewController {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User Interface
    fileprivate var pageControlContainerView = UIView()
    fileprivate var pageControl              = UIPageControl()
    fileprivate var continueButton           = UIBarButtonItem()
    fileprivate let backgroundAlpha: CGFloat = 0.85
    
    // Resources
    fileprivate let continueButtonResources = PreferredButtonResource(image: "navigationOnboardingContinue", title: "ginivision.navigationbar.onboarding.continue", comment: "Button title in the navigation bar for the continue button on the onboarding screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarOnboardingTitleContinueButton)

    // Output
    fileprivate var completionBlock: OnboardingContainerCompletionBlock?
    
    init(withCompletion completion: @escaping OnboardingContainerCompletionBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        completionBlock = completion
        
        // Configure content controller
        var pages = GiniConfiguration.sharedConfiguration.onboardingPages
        pages.append(UIView()) // Add an empty last page to transition nicely back to camera
        contentController = OnboardingViewController(pages: pages,
                                                     scrollViewDelegate: self)
        
        // Configure title
        title = GiniConfiguration.sharedConfiguration.navigationBarOnboardingTitle
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor.withAlphaComponent(backgroundAlpha)
        
        // Configure page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = GiniConfiguration.sharedConfiguration.onboardingCurrentPageIndicatorColor
        pageControl.pageIndicatorTintColor = GiniConfiguration.sharedConfiguration.onboardingPageIndicatorColor
        
        // Configure continue button
        continueButton = GiniBarButtonItem(
            image: continueButtonResources.preferredImage,
            title: continueButtonResources.preferredText,
            style: .plain,
            target: self,
            action: #selector(nextPage)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        view.addSubview(pageControlContainerView)
        pageControlContainerView.addSubview(pageControl)
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
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // Current onboarding page needs to be centered during transition (after ScrollView changes its frame)
        coordinator.animate(alongsideTransition: { (_) in
            (self.contentController as? OnboardingViewController)?.centerTo(page: self.pageControl.currentPage)
        })
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    // MARK: Actions
    
    @IBAction func close() {
        dismiss(animated: false, completion: completionBlock)
    }
    
    @IBAction func nextPage() {
        (contentController as? OnboardingViewController)?.scrollToNextPage(true)
    }
    
    // MARK: Constraints
    
    fileprivate func addConstraints() {
        let superview = self.view

        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0, priority: 750)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .width, relatedBy: .equal, toItem: superview, attribute: .width, multiplier: 1, constant: 0, priority: 750)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: superview, attribute: .width, multiplier: 1, constant: 0, priority: 999)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        
        // Page control container view
        pageControlContainerView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: pageControlContainerView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0, priority: 750)
        ConstraintUtils.addActiveConstraint(item: pageControlContainerView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: pageControlContainerView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: pageControlContainerView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: pageControlContainerView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: pageControl, attribute: .height, multiplier: 1.1, constant: 0)
        
        // Page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: pageControl, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 55)
        ConstraintUtils.addActiveConstraint(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: pageControlContainerView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: pageControl, attribute: .centerY, relatedBy: .equal, toItem: pageControlContainerView, attribute: .centerY, multiplier: 1, constant: 0)
    }
}

// MARK: UIScrollViewDelegate

extension OnboardingContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setPageControl(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setPageControl(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
    }
    
    fileprivate func setPageControl(_ scrollView: UIScrollView) {
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
