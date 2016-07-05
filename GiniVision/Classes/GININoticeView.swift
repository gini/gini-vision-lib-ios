//
//  GININoticeView.swift
//  GiniVision
//
//  Created by Peter Pult on 01/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

public typealias GININoticeAction = () -> ()

internal class GININoticeView: UIView {
    
    private var textLabel = UILabel()
    
    init(text: String) {
        super.init(frame: CGRectZero)
        
        // TODO: Add style depending on a type `Error`, `Information`
        
        // Set text
        textLabel.text = text
        
        // Configure label
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor.whiteColor()
        
        // Configure view hierachy
        addSubview(textLabel)
        
        // Configure colors
        backgroundColor = UIColor.redColor()
        
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
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self
        
        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 20)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 20)
    }
    
}