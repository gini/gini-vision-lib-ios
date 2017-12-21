//
//  OnboardingContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Block that will be executed when the onboarding was dismissed.
 */
internal typealias OnboardingContainerCompletionBlock = () -> Void

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
    
    // Output
    fileprivate var completionBlock: OnboardingContainerCompletionBlock?
    
    init(giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration,
         withCompletion completion: @escaping OnboardingContainerCompletionBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        completionBlock = completion
        
        // Configure content controller
        var pages = giniConfiguration.onboardingPages
        pages.append(UIView()) // Add an empty last page to transition nicely back to camera
        contentController = OnboardingViewController(pages: pages,
                                                     scrollViewDelegate: self)
        
        // Configure title
        title = giniConfiguration.navigationBarOnboardingTitle
        
        // Configure colors
        view.backgroundColor = giniConfiguration.backgroundColor.withAlphaComponent(backgroundAlpha)
        
        // Configure page control
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = giniConfiguration.onboardingCurrentPageIndicatorColor
        pageControl.pageIndicatorTintColor = giniConfiguration.onboardingPageIndicatorColor
        
        // Configure continue button
        let continueButtonResources =
            PreferredButtonResource(image: "navigationOnboardingContinue",
                                    title: "ginivision.navigationbar.onboarding.continue",
                                    comment: "Button title in the navigation bar for the " +
                                             "continue button on the onboarding screen",
                                    configEntry: giniConfiguration.navigationBarOnboardingTitleContinueButton)
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
        super.viewWillTransition(to: size, with: coordinator)
        
        // Current onboarding page needs to be centered during transition (after ScrollView changes its frame)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            (self.contentController as? OnboardingViewController)?.centerTo(page: self.pageControl.currentPage)
        })
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
        Contraints.active(item: containerView, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        Contraints.active(item: containerView, attr: .bottom, relatedBy: .greaterThanOrEqual, to: superview,
                          attr: .bottom, priority: 750)
        Contraints.active(item: containerView, attr: .width, relatedBy: .equal, to: superview, attr: .width,
                          priority: 750)
        Contraints.active(item: containerView, attr: .width, relatedBy: .lessThanOrEqual, to: superview,
                          attr: .width, priority: 999)
        Contraints.active(item: containerView, attr: .centerX, relatedBy: .equal, to: superview, attr: .centerX)
        
        // Page control container view
        pageControlContainerView.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: pageControlContainerView, attr: .top, relatedBy: .equal, to: containerView,
                          attr: .bottom, priority: 750)
        Contraints.active(item: pageControlContainerView, attr: .trailing, relatedBy: .equal, to: superview,
                          attr: .trailing)
        Contraints.active(item: pageControlContainerView, attr: .bottom, relatedBy: .equal, to: superview,
                          attr: .bottom)
        Contraints.active(item: pageControlContainerView, attr: .leading, relatedBy: .equal, to: superview,
                          attr: .leading)
        Contraints.active(item: pageControlContainerView, attr: .height, relatedBy: .greaterThanOrEqual,
                          to: pageControl, attr: .height, multiplier: 1.1)
        
        // Page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: pageControl, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 55)
        Contraints.active(item: pageControl, attr: .centerX, relatedBy: .equal, to: pageControlContainerView,
                          attr: .centerX)
        Contraints.active(item: pageControl, attr: .centerY, relatedBy: .equal, to: pageControlContainerView,
                          attr: .centerY)
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
            // Lighten the background when overflowing to the right
            alpha = min(backgroundAlpha, 1 - fabs(frameOffsetX/fixedFrame.width))
        } else {
            // Darken the background when overflowing to the left
            alpha = max(backgroundAlpha, fabs((contentOffsetX*0.3)/fixedFrame.width) + backgroundAlpha)
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

// MARK: User defaults flags

extension OnboardingContainerViewController {
    static var willBeShown: Bool {
        return (GiniConfiguration.sharedConfiguration.onboardingShowAtFirstLaunch &&
            !UserDefaults.standard.bool(forKey: "ginivision.defaults.onboardingShowed")) ||
            GiniConfiguration.sharedConfiguration.onboardingShowAtLaunch
    }
}
