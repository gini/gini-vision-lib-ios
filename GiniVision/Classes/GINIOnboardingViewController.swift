//
//  GINIOnboardingViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `GINIOnboardingViewController` provides a custom onboarding screen which presents some introductory screens to the user on how to get the camera in a perfect position etc. By default, three screens are pre-configured.
 
 A blank page will be inserted at the end, which makes it possible to "swipe away" the onboarding. To achieve this, the container class needs to implement `UIScrollViewDelegate` and dismiss the view when the last page is reached. With the `UIScrollViewDelegate` callbacks it is also possible to add a custom page control and update the current page accordingly.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.onboarding.title` (Screen API only.)
 * `ginivision.navigationbar.onboarding.continue` (Screen API only.)
 * `ginivision.onboarding.firstPage`
 * `ginivision.onboarding.secondPage`
 * `ginivision.onboarding.thirdPage`
 
 **Image resources for this screen**
 
 * `onboardingPage1`
 * `onboardingPage2`
 * `onboardingPage3`
 * `navigationOnboardingContinue` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. They are marked with _Screen API only_.

 - note: Component API only.
 */
@objc public final class GINIOnboardingViewController: UIViewController {
    
    // User interface
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var pages = [UIView]()
    
    /**
     Designated intitializer for the `GINIOnboardingViewController` which allows to pass a custom set of views which will be displayed in horizontal scroll view.
     
     - parameter pages:              An array of views to be displayed in the scroll view.
     - parameter scrollViewDelegate: The receiver for the scroll view delegate callbacks.
     
     - returns: A view controller instance intended to allow the user to get a brief overview over the functionality provided by the Gini Vision Library.
     */
    public init(pages: [UIView], scrollViewDelegate: UIScrollViewDelegate) {
        super.init(nibName: nil, bundle: nil)
        
        // Set pages
        self.pages = pages
        let emptyView = UIView()
        emptyView.backgroundColor = UIColor.orangeColor()
        self.pages.append(emptyView) // Add an empty last page
        
        // Configure scroll view
        scrollView.delegate = scrollViewDelegate
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        
        // Configure colors
        view.backgroundColor = UIColor.clearColor()
        view.backgroundColor = UIColor.redColor()
        contentView.backgroundColor = UIColor.purpleColor()
        
        // Configure view hierachy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        for page in self.pages {
            contentView.addSubview(page)
        }
        
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
        let pagesCount = CGFloat(pages.count)
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: contentView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .Bottom, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Width, multiplier: pagesCount, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .Height, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 1, constant: 0)
        
        for page in pages {
            page.translatesAutoresizingMaskIntoConstraints = false
            UIViewController.addActiveConstraint(item: page, attribute: .Width, relatedBy: .Equal, toItem: page, attribute: .Height, multiplier: 3/4, constant: 0)
            UIViewController.addActiveConstraint(item: page, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: page, attribute: .Width, relatedBy: .Equal, toItem: contentView, attribute: .Width, multiplier: 1/pagesCount, constant: 0)
            if page == pages.first {
                UIViewController.addActiveConstraint(item: page, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 0)
            } else {
                let previousPage = pages[pages.indexOf(page)! - 1]
                UIViewController.addActiveConstraint(item: page, attribute: .Leading, relatedBy: .Equal, toItem: previousPage, attribute: .Trailing, multiplier: 1, constant: 0)
            }
        }
    }
    
}
