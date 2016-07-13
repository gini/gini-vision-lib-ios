//
//  GINICameraNotAuthorizedView.swift
//  GiniVision
//
//  Created by Peter Pult on 06/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GINICameraNotAuthorizedView: UIView {
    
    // User interface
    private var label = UILabel()
    private var button = UIButton()
    private var imageView = UIImageView()
    private var contentView = UIView()
    
    // Images
    private var noCameraImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraNotAuthorizedIcon")
    }
    
    init() {
        super.init(frame: CGRectZero)
        
        // Configure image view
        imageView.image = noCameraImage
        imageView.contentMode = .ScaleAspectFit
        
        // Configure label
        label.text = GINIConfiguration.sharedConfiguration.cameraNotAuthorizedText
        label.numberOfLines = 0
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.font = GINIConfiguration.sharedConfiguration.cameraNotAuthorizedTextFont
        
        // Configure button
        button.setTitle(GINIConfiguration.sharedConfiguration.cameraNotAuthorizedButtonTitle, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.8), forState: .Highlighted)
        button.titleLabel?.font = GINIConfiguration.sharedConfiguration.cameraNotAuthorizedButtonFont
        button.addTarget(self, action: #selector(openSettings), forControlEvents: .TouchUpInside)
        
        // Configure view hierachy
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        // Add constraints
        addConstraints()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func openSettings(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
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
        UIViewController.addActiveConstraint(item: imageView, attribute: .Height, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 75)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 50)
        UIViewController.addActiveConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)
        
        // Text label
        label.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: label, attribute: .Top, relatedBy: .Equal, toItem: imageView, attribute: .Bottom, multiplier: 1, constant: 35)
        UIViewController.addActiveConstraint(item: label, attribute: .Trailing, relatedBy: .Equal, toItem: contentView, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: label, attribute: .Leading, relatedBy: .Equal, toItem: contentView, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 250)
        UIViewController.addActiveConstraint(item: label, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 70)
        
        // Button
        button.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: label, attribute: .Bottom, multiplier: 1, constant: 10)
        UIViewController.addActiveConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: label, attribute: .Width, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 35)
        UIViewController.addActiveConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: contentView, attribute: .CenterX, multiplier: 1, constant: 0)
    }
    
}