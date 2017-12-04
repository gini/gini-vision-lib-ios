//
//  OnboardingViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `OnboardingViewController` provides a custom onboarding screen which presents some introductory screens to the user on how to get the camera in a perfect position etc. By default, three screens are pre-configured.
 
 To allow displaying the onboarding as a transparent modal view, set the `modalPresentationStyle` of the container class to `.OverCurrentContext`. Add a blank page at the end to make it possible to "swipe away" the onboarding. To achieve this, the container class needs to implement `UIScrollViewDelegate` and dismiss the view when the last (empty) page is reached. With the `UIScrollViewDelegate` callbacks it is also possible to add a custom page control and update the current page accordingly.
 
 Use the `OnboardingPage` class to quickly create custom onboarding pages in a nice consistent design. See below how easy it is to present an custom onboarding view controller.
 
     let pages = [
         OnboardingPage(image: myOnboardingImage1, text: "My Onboarding Page 1"),
         OnboardingPage(image: myOnboardingImage2, text: "My Onboarding Page 2"),
         OnboardingPage(image: myOnboardingImage3, text: "My Onboarding Page 3")
         OnboardingPage(image: myOnboardingImage4, text: "My Onboarding Page 4")
     ]
     let onboardingController = OnboardingViewController(pages: pages, scrollViewDelegate: self)
     presentViewController(onboardingController, animated: true, completion: nil)
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.onboarding.title` (Screen API only.)
 * `ginivision.navigationbar.onboarding.continue` (Screen API only.)
 * `ginivision.onboarding.firstPage`
 * `ginivision.onboarding.secondPage`
 * `ginivision.onboarding.thirdPage`
 * `ginivision.onboarding.fourthPage`
 
 **Image resources for this screen**
 
 * `onboardingPage1` (Both iPhone and iPad sizes)
 * `onboardingPage2` (Both iPhone and iPad sizes)
 * `onboardingPage3` (Both iPhone and iPad sizes)
 * `onboardingPage4` (Only iPad size)
 * `navigationOnboardingContinue` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. They are marked with _Screen API only_.

 - note: Component API only.
 */
@objc public final class OnboardingViewController: UIViewController {
    
    
    /**
     Scroll view used to display different onboarding pages.
     */
    public var scrollView = UIScrollView()
    
    /**
     Array of views displayed as pages inside the scroll view.
     */
    public var pages = [UIView]()

    // User interface
    private var contentView = UIView()

    /**
     Designated intitializer for the `OnboardingViewController` which allows to pass a custom set of views which will be displayed in horizontal scroll view.
     
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
     Convenience initializer for the `OnboardingViewController` which will set a predefined set of views as the onboarding pages.
     
     - parameter scrollViewDelegate: The receiver for the scroll view delegate callbacks.
     
     - returns: A view controller instance intended to allow the user to get a brief overview over the functionality provided by the Gini Vision Library.
     */
    public convenience init(scrollViewDelegate: UIScrollViewDelegate?) {
        self.init(pages: GiniConfiguration.sharedConfiguration.onboardingPages, scrollViewDelegate: scrollViewDelegate)
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
    
    /**
     Center page in case it is not centered (i.e after rotation)
     
     */
    public func centerTo(page:Int) {
        var offset = scrollView.contentOffset
        offset.x = scrollView.frame.width * CGFloat(page)
                
        scrollView.setContentOffset(offset, animated: true)
    }
        
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        let pagesCount = CGFloat(pages.count)
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: scrollView, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        Contraints.active(item: scrollView, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        Contraints.active(item: scrollView, attr: .bottom, relatedBy: .equal, to: superview, attr: .bottom)
        Contraints.active(item: scrollView, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: contentView, attr: .top, relatedBy: .equal, to: scrollView, attr: .top)
        Contraints.active(item: contentView, attr: .trailing, relatedBy: .equal, to: scrollView, attr: .trailing)
        Contraints.active(item: contentView, attr: .bottom, relatedBy: .equal, to: scrollView, attr: .bottom)
        Contraints.active(item: contentView, attr: .leading, relatedBy: .equal, to: scrollView, attr: .leading)
        Contraints.active(item: contentView, attr: .width, relatedBy: .equal, to: scrollView, attr: .width, multiplier: pagesCount)
        Contraints.active(item: contentView, attr: .height, relatedBy: .equal, to: scrollView, attr: .height)
        
        for page in pages {
            page.translatesAutoresizingMaskIntoConstraints = false
            Contraints.active(item: page, attr: .top, relatedBy: .equal, to: contentView, attr: .top)
            Contraints.active(item: page, attr: .bottom, relatedBy: .equal, to: contentView, attr: .bottom)
            Contraints.active(item: page, attr: .width, relatedBy: .equal, to: contentView, attr: .width, multiplier: 1/pagesCount)
            if page == pages.first {
                Contraints.active(item: page, attr: .leading, relatedBy: .equal, to: contentView, attr: .leading)
            } else {
                let previousPage = pages[pages.index(of: page)! - 1]
                Contraints.active(item: page, attr: .leading, relatedBy: .equal, to: previousPage, attr: .trailing)
            }
        }
    }
    
}
