//
//  GINIOnboardingPage.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Custom view to easily create onboarding pages which can then be used in `GINIOnboardingViewController`. Simply pass an image and a name and they will be beautifully aligned and displayed to the user.
 
 - note: The text length should not exceed 50 characters, depending on the font used, and should preferably stretch out over three lines.
 */
@objc public final class GINIOnboardingPage: UIView {
    
    private var contentView = UIView()
    private var imageView = UIImageView()
    private var textLabel = UILabel()
    
    /**
     Designated initializer for the `GINIOnboardingPage` class which allows to create a custom onboarding page just by passing an image and a text. The text will be displayed underneath the image.
     
     - parameter image: The image to be displayed.
     - parameter text:  The text to be displayed underneath the image.
     
     - returns: A simple custom view to be displayed in the onboarding.
     */
    public init(image: UIImage, text: String) {
        super.init(frame: CGRectZero)
        
        // Set image and text
        imageView.image = image
        textLabel.text = text
        
        // Configure label
        textLabel.numberOfLines = 0
        textLabel.textColor = GINIConfiguration.sharedConfiguration.onboardingTextColor
        textLabel.textAlignment = .Center
        textLabel.font = GINIConfiguration.sharedConfiguration.onboardingTextFont
        
        // Configure view hierachy
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        
        // Add constraints
        addConstraints()
    }
    
    /**
     Convenience initializer for the `GINIOnboardingPage` class which allows to create a custom onboarding page simply by passing an image name and a text. The text will be displayed underneath the image.
     
     - parameter imageName: The name of the image to be displayed.
     - parameter text:      The text to be displayed underneath the image.
     
     - returns: A simple custom view to be displayed in the onboarding or `nil` when no image with the given name could be found.
     */
    public convenience init?(imageNamed imageName: String, text: String) {
        guard let image = UIImageNamedPreferred(named: imageName) else { return nil }
        self.init(image: image, text: text)
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
        let superview = self
            
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: contentView, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: superview, attribute: .Top, multiplier: 1, constant: 30)
        UIViewController.addActiveConstraint(item: contentView, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: contentView, attribute: .CenterY, relatedBy: .Equal, toItem: superview, attribute: .CenterY, multiplier: 1, constant: 5, priority: 999)
    
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .Width, multiplier: 1, constant: 204)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Width, multiplier: 1, constant: 75)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 120)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 100)
        UIViewController.addActiveConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)

        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 35)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 250)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 70)
    }
    
}
