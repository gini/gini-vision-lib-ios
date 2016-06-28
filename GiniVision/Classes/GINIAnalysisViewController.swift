//
//  GINIAnalysisViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `GINIAnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity. The user should have the option of canceling the process by navigating back to the review screen.
 
 **Text ressources on this screen**
 * `ginivision.navigationbar.analysis.back`
 * `ginivision.navigationbar.review.back`
 
 **Image ressources on this screen**
 * `navigationAnalysisBack` (Screen API only.)
 
 - note: Component API only.
 */
public final class GINIAnalysisViewController: UIViewController {
    
    // User interface
    private var imageView = UIImageView()
    private var loadingIndicatorView = UIActivityIndicatorView()
    
    /**
     Designated intitializer for the `GINIAnalysisViewController`.
     
     - parameter imageData: Reviewed image data ready for analysis.
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public init(_ imageData: NSData) {
        super.init(nibName: nil, bundle: nil)
        
        // Configure image view
        imageView.image = UIImage(data: imageData)
        imageView.contentMode = .ScaleAspectFit
        
        // Configure loading indicator view
        loadingIndicatorView.color = GINIConfiguration.sharedConfiguration.analysisLoadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.activityIndicatorViewStyle = .WhiteLarge
        
        // Configure colors
        view.backgroundColor = UIColor.clearColor()
        
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
    private func addConstraints() {
        let superview = self.view

        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 3/4, constant: 0)
        
        
        // Loading indicator view
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: loadingIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: loadingIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: imageView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
}
