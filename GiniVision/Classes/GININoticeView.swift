//
//  GININoticeView.swift
//  GiniVision
//
//  Created by Peter Pult on 01/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

/**
 Block which will be executed when a notice is tapped. Can be used to restart a process or to give the user further guidance.
 
 - note: Screen API only.
 */
public typealias GININoticeAction = () -> ()

internal enum GININoticeType {
    case information, error
}

internal class GININoticeView: UIView {
    
    // User interface
    fileprivate var textLabel = UILabel()
    
    // Properties
    fileprivate var userAction: GININoticeAction?
    fileprivate var type = GININoticeType.information
    
    init(text: String, noticeType: GININoticeType = .information, action: GININoticeAction? = nil) {
        super.init(frame: CGRect.zero)
        
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
        textLabel.textAlignment = .center
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.7
        textLabel.font = GINIConfiguration.sharedConfiguration.noticeFont
        
        // Configure UI depending on type
        switch type {
        case .information:
            textLabel.textColor = GINIConfiguration.sharedConfiguration.noticeInformationTextColor
            backgroundColor = GINIConfiguration.sharedConfiguration.noticeInformationBackgroundColor
        case .error:
            textLabel.textColor = GINIConfiguration.sharedConfiguration.noticeErrorTextColor
            backgroundColor = GINIConfiguration.sharedConfiguration.noticeErrorBackgroundColor
        }
        
        // Configure view hierachy
        addSubview(textLabel)
        
        // Configure colors
        backgroundColor = backgroundColor?.withAlphaComponent(0.8)
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func handleTap(_ sender: UIGestureRecognizer) {
        switch type {
        case .information:
            return
        case .error:
            hide {
                self.userAction?()
            }
        }
    }
    
    // MARK: Toggle options
    func show(_ animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
            })
        } else {
            self.alpha = 1.0
        }
    }
    
    func hide(_ animated: Bool = true, completion: (() -> ())?) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }, completion: { (success: Bool) in
                completion?()
                self.removeFromSuperview()
            }) 
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
    
    fileprivate func addConstraints() {
        if let superview = superview {
            
            // Superview
            self.translatesAutoresizingMaskIntoConstraints = false
            UIViewController.addActiveConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
            UIViewController.addActiveConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35)
        }
        
        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -20, priority: 999)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 20)
    }
    
}
