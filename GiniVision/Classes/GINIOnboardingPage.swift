//
//  GINIOnboardingPage.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Custom view to easily create onboarding pages which can then be used in `GINIOnboardingViewController`. Simply pass an image and a name. Both will be beautifully aligned and displayed to the user.
 
 - note: The text length should not exceed 50 characters, depending on the font used, and should preferably stretch out over three lines.
 */
@objc public final class GINIOnboardingPage: UIView {
    
    fileprivate var contentView = UIView()
    fileprivate var imageView = UIImageView()
    fileprivate var textLabel = UILabel()
    
    /**
     Designated initializer for the `GINIOnboardingPage` class which allows to create a custom onboarding page just by passing an image and a text. The text will be displayed underneath the image.
     
     - parameter image: The image to be displayed.
     - parameter text:  The text to be displayed underneath the image.
     
     - returns: A simple custom view to be displayed in the onboarding.
     */
    public init(image: UIImage, text: String) {
        super.init(frame: CGRect.zero)
        
        // Set image and text
        imageView.image = image
        textLabel.text = text
        
        // Configure label
        textLabel.numberOfLines = 0
        textLabel.textColor = GINIConfiguration.sharedConfiguration.onboardingTextColor
        textLabel.textAlignment = .center
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
    fileprivate func addConstraints() {
        let superview = self
            
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: contentView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: superview, attribute: .top, multiplier: 1, constant: 30)
        ConstraintUtils.addActiveConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 5, priority: 999)
    
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 204)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 75)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 120)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 100)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)

        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 35)
        ConstraintUtils.addActiveConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: textLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250)
        ConstraintUtils.addActiveConstraint(item: textLabel, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 70)
    }
    
}
