//
//  GINIOnboardingViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `GINIOnboardingViewController` provides a custom onboarding screen which presents some introducing screens to the user on how to get the camera in a perfect position etc. Per default, three screens are pre-configured.
 
 - note: Component API only.
 */
public final class GINIOnboardingViewController: UIViewController {
    
    // User interface
    private var scrollView = UIScrollView()
    private var pageControl = GINIPageControl()
    private var pages = [GINIOnboardingPage]()
    
    public init(pages: [GINIOnboardingPage]) {
        super.init(nibName: nil, bundle: nil)
        
        // Set pages
        self.pages = pages
        
        // Configure scroll view
        scrollView.delegate = self
        
        // Configure colors
        view.backgroundColor = UIColor.clearColor()
        
        // Configure view hierachy
        
        // Add constraints
        addConstraints()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view
    }
    
}

extension GINIOnboardingViewController: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // TODO:
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // TODO:
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
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