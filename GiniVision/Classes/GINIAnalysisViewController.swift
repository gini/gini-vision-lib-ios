//
//  GINIAnalysisViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Delegate which can be used to communicate back to the analysis screen allowing to display custom messages on screen.
 
 - note: Screen API only.
 */
@objc public protocol GINIAnalysisDelegate {
    
    /**
     Will display an error view on the analysis screen with a custom message.
     The provided action will be called, when the user taps on the error view.
     
     - parameter message: The error message to be displayed.
     - parameter action:  The action to be performed after the user tapped the error view.
     */
    func displayError(withMessage message: String?, andAction action: GININoticeAction?)
}

/**
 The `GINIAnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity. The user should have the option of canceling the process by navigating back to the review screen.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.analysis.back` (Screen API only.)
 
 **Image resources for this screen**
 
 * `navigationAnalysisBack` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. These are marked with _Screen API only_.

 - note: Component API only.
 */
@objc public final class GINIAnalysisViewController: UIViewController {
    
    // User interface
    fileprivate var imageView = UIImageView()
    fileprivate var loadingIndicatorView = UIActivityIndicatorView()
    
    /**
     Designated intitializer for the `GINIAnalysisViewController`.
     
     - parameter imageData: Reviewed image data ready for analysis.
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public init(_ imageData: Data) {
        super.init(nibName: nil, bundle: nil)
        
        // Configure image view
        imageView.image = UIImage(data: imageData)
        imageView.contentMode = .scaleAspectFit
        
        // Configure loading indicator view
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.activityIndicatorViewStyle = .whiteLarge
        loadingIndicatorView.color = GINIConfiguration.sharedConfiguration.analysisLoadingIndicatorColor
        
        // Configure view hierachy
        view.addSubview(imageView)
        view.addSubview(loadingIndicatorView)
        
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
    
    // MARK: Toggle animation
    /**
     Displays a loading activity indicator. Should be called when document analysis is started.
     
     - note: To change the color of the loading animation use `analysisLoadingIndicatorColor` on the `GINIConfiguration` class.
     */
    public func showAnimation() {
        loadingIndicatorView.startAnimating()
    }
    
    /**
     Hides the loading activity indicator. Should be called when document analysis is finished.
     */
    public func hideAnimation() {
        loadingIndicatorView.stopAnimating()
    }
        
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view

        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
                
        // Loading indicator view
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: loadingIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: loadingIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0)
    }
    
}
