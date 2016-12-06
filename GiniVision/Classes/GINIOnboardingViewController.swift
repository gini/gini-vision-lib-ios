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
 
 To allow displaying the onboarding as a transparent modal view, set the `modalPresentationStyle` of the container class to `.OverCurrentContext`. Add a blank page at the end to make it possible to "swipe away" the onboarding. To achieve this, the container class needs to implement `UIScrollViewDelegate` and dismiss the view when the last (empty) page is reached. With the `UIScrollViewDelegate` callbacks it is also possible to add a custom page control and update the current page accordingly.
 
 Use the `GINIOnboardingPage` class to quickly create custom onboarding pages in a nice consistent design. See below how easy it is to present an custom onboarding view controller.
 
     let pages = [
         GINIOnboardingPage(image: myOnboardingImage1, text: "My Onboarding Page 1"),
         GINIOnboardingPage(image: myOnboardingImage2, text: "My Onboarding Page 2"),
         GINIOnboardingPage(image: myOnboardingImage3, text: "My Onboarding Page 3")
     ]
     let onboardingController = GINIOnboardingViewController(pages: pages, scrollViewDelegate: self)
     presentViewController(onboardingController, animated: true, completion: nil)
 
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
    fileprivate var scrollView  = UIScrollView()
    fileprivate var contentView = UIView()
    fileprivate var pages       = [UIView]()

    /**
     Designated intitializer for the `GINIOnboardingViewController` which allows to pass a custom set of views which will be displayed in horizontal scroll view.
     
     - parameter pages:              An array of views to be displayed in the scroll view.
     - parameter scrollViewDelegate: The receiver for the scroll view delegate callbacks.
     
     - returns: A view controller instance intended to allow the user to get a brief overview over the functionality provided by the Gini Vision Library.
     */
    public init(pages: [UIView], scrollViewDelegate: UIScrollViewDelegate?) {
        super.init(nibName: nil, bundle: nil)
        
        // Set pages
        self.pages = pages
        
        // Configure scroll view
        scrollView.delegate = scrollViewDelegate
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
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
     Convenience initializer for the `GINIOnboardingViewController` which will set a predefined set of views as the onboarding pages.
     
     - parameter scrollViewDelegate: The receiver for the scroll view delegate callbacks.
     
     - returns: A view controller instance intended to allow the user to get a brief overview over the functionality provided by the Gini Vision Library.
     */
    public convenience init(scrollViewDelegate: UIScrollViewDelegate?) {
        self.init(pages: GINIConfiguration.sharedConfiguration.onboardingPages, scrollViewDelegate: scrollViewDelegate)
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Scrolls the scroll view to the next page.
     
     - parameter animated: Defines whether scrolling should be animated.
     */
    public func scrollToNextPage(_ animated: Bool) {
        var offset = scrollView.contentOffset
        offset.x += scrollView.frame.width
        // Make sure there is no overflow and scrolling only happens from page to page
        guard offset.x < scrollView.contentSize.width && offset.x.truncatingRemainder(dividingBy: scrollView.frame.width) == 0 else {
            return
        }
        scrollView.setContentOffset(offset, animated: animated)
    }
        
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        let pagesCount = CGFloat(pages.count)
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: scrollView, attribute: .width, multiplier: pagesCount, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: scrollView, attribute: .height, multiplier: 1, constant: 0)
        
        for page in pages {
            page.translatesAutoresizingMaskIntoConstraints = false
            UIViewController.addActiveConstraint(item: page, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: page, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: page, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1/pagesCount, constant: 0)
            if page == pages.first {
                UIViewController.addActiveConstraint(item: page, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
            } else {
                let previousPage = pages[pages.index(of: page)! - 1]
                UIViewController.addActiveConstraint(item: page, attribute: .leading, relatedBy: .equal, toItem: previousPage, attribute: .trailing, multiplier: 1, constant: 0)
            }
        }
    }
    
}
