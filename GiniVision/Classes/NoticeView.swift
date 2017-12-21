//
//  NoticeView.swift
//  GiniVision
//
//  Created by Peter Pult on 01/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

/**
 Block that will be executed when a notice is tapped. Can be used to restart a
 process or to give the user further guidance.
 
 - note: Screen API only.
 */
public typealias NoticeAction = () -> Void

internal enum NoticeType {
    case information, error
}

internal class NoticeView: UIView {
    
    // User interface
    fileprivate var textLabel = UILabel()
    
    // Properties
    fileprivate var userAction: NoticeAction?
    fileprivate var type = NoticeType.information
    
    init(text: String, noticeType: NoticeType = .information, action: NoticeAction? = nil) {
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
        textLabel.font = GiniConfiguration.sharedConfiguration.customFont == nil ?
            GiniConfiguration.sharedConfiguration.noticeFont :
            GiniConfiguration.sharedConfiguration.font.regular.withSize(12)
        
        // Configure UI depending on type
        switch type {
        case .information:
            textLabel.textColor = GiniConfiguration.sharedConfiguration.noticeInformationTextColor
            backgroundColor = GiniConfiguration.sharedConfiguration.noticeInformationBackgroundColor
        case .error:
            textLabel.textColor = GiniConfiguration.sharedConfiguration.noticeErrorTextColor
            backgroundColor = GiniConfiguration.sharedConfiguration.noticeErrorBackgroundColor
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
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1.0
            }
        } else {
            self.alpha = 1.0
        }
    }
    
    func hide(_ animated: Bool = true, completion: (() -> Void)?) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }, completion: { _ in
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
            Contraints.active(item: self, attr: .top, relatedBy: .equal, to: superview, attr: .top)
            Contraints.active(item: self, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
            Contraints.active(item: self, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
            Contraints.active(item: self, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 35)
        }
        
        // Text label
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: textLabel, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Contraints.active(item: textLabel, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -20, priority: 999)
        Contraints.active(item: textLabel, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom)
        Contraints.active(item: textLabel, attr: .leading, relatedBy: .equal, to: self, attr: .leading, constant: 20)
    }
    
}
