//
//  GININoticeView.swift
//  GiniVision
//
//  Created by Peter Pult on 01/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

public typealias GININoticeAction = () -> ()

public enum GININoticeType {
    case Information, Error
}

internal class GININoticeView: UIView {
    
    // User interface
    private var textLabel = UILabel()
    
    // Properties
    private var userAction: GININoticeAction?
    private var type = GININoticeType.Information
    
    init(text: String, noticeType: GININoticeType = .Information, action: GININoticeAction? = nil) {
        super.init(frame: CGRectZero)
        
        // Hide when initialized
        alpha = 0.0
        
        // Set attributes
        textLabel.text = text
        userAction = action
        type = noticeType
        
        // Configure tap action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        // Configure label
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .Center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.7
        textLabel.font = GINIConfiguration.sharedConfiguration.noticeFont
        
        // Configure UI depending on type
        switch type {
        case .Information:
            textLabel.textColor = GINIConfiguration.sharedConfiguration.noticeInformationTextColor
            backgroundColor = GINIConfiguration.sharedConfiguration.noticeInformationBackgroundColor
        case .Error:
            textLabel.textColor = GINIConfiguration.sharedConfiguration.noticeErrorTextColor
            backgroundColor = GINIConfiguration.sharedConfiguration.noticeErrorBackgroundColor
        }
        
        // Configure view hierachy
        addSubview(textLabel)
        
        // Configure colors
        backgroundColor = backgroundColor?.colorWithAlphaComponent(0.8)
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTap(sender: UIGestureRecognizer) {
        switch type {
        case .Information:
            return
        case .Error:
            hide {
                self.userAction?()
            }
        }
    }
    
    // MARK: Toggle options
    func show(animated: Bool = true) {
        if animated {
            UIView.animateWithDuration(0.5, animations: {
                self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    func hide(animated: Bool = true, completion: (() -> ())?) {
        if animated {
            UIView.animateWithDuration(0.5, animations: {
                self.alpha = 0.0
            }) { (success: Bool) in
                completion?()
                self.removeFromSuperview()
            }
        } else {
            self.alpha = 0.0
            completion?()
            self.removeFromSuperview()
        }
        
    }
        
    // MARK: Constraints
    override func didMoveToSuperview() {
        
        // Add constraints
        addConstraints()
    }
    
    private func addConstraints() {
        if let superview = superview {
            
            // Superview
            self.translatesAutoresizingMaskIntoConstraints = false
            UIViewController.addActiveConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 35)
        }
        
        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: -20, priority: 999)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 20)
    }
    
}