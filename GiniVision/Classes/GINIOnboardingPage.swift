//
//  GINIOnboardingPage.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

public class GINIOnboardingPage: UIView {
    
    private var imageView = UIImageView()
    private var textLabel = UILabel()
    
    public init(image: UIImage, text: String) {
        super.init(frame: CGRectZero)
        
        // Set image and text
        imageView.image = image
        textLabel.text = text
        
        // Configure view hierachy
        self.addSubview(imageView)
        self.addSubview(textLabel)
        
        // Add constraints
        addConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.superview
        
        // View
        self.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 3/4, constant: 0)
        UIViewController.addActiveConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        
        
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .Width, multiplier: 1, constant: 204)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Width, multiplier: 1, constant: 75)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 120)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 100)
        UIViewController.addActiveConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: textLabel, attribute: .Top, multiplier: 1, constant: 35)
        
        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 250)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 70)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
    }
    
}