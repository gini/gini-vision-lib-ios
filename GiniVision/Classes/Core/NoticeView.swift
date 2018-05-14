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

struct NoticeAction {
    let title: String
    let action: () -> Void
}

internal enum NoticeType {
    case information, error
}

final class NoticeView: UIView {
    
    // User interface
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12 / 14
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        label.font = self.giniConfiguration.customFont.isEnabled ?
            self.giniConfiguration.customFont.regular.withSize(14) :
            self.giniConfiguration.noticeFont
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)

        button.titleLabel?.textColor = self.giniConfiguration.noticeErrorTextColor
        button.titleLabel?.font =  self.giniConfiguration.customFont.bold.withSize(16)
        button.addTarget(self, action: #selector(self.didTapActionButton), for: .touchUpInside)
        return button
    }()
    
    // Properties
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate var userAction: NoticeAction?
    
    init(giniConfiguration: GiniConfiguration = .shared,
         text: String,
         type: NoticeType = .information,
         noticeAction: NoticeAction? = nil) {
        self.giniConfiguration = giniConfiguration
        super.init(frame: CGRect.zero)
        
        let textColor: UIColor
        switch type {
        case .information:
            textColor = giniConfiguration.noticeInformationTextColor
            backgroundColor = giniConfiguration
                .noticeInformationBackgroundColor
                .withAlphaComponent(0.8)
        case .error:
            textColor = giniConfiguration.noticeErrorTextColor
            backgroundColor = giniConfiguration
                .noticeErrorBackgroundColor
                .withAlphaComponent(0.9)
        }

        if let noticeAction = noticeAction {
            userAction = noticeAction
            actionButton.setTitle(noticeAction.title, for: .normal)
            actionButton.titleLabel?.textColor = textColor
            addSubview(actionButton)
        }
        
        textLabel.text = text
        textLabel.textColor = textColor
        addSubview(textLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0.0
    }
    
    @objc func didTapActionButton() {
        self.userAction?.action()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        addConstraints()
    }
    
    fileprivate func addConstraints() {
        if let superview = superview {
            // Superview
            Constraints.active(item: self, attr: .top, relatedBy: .equal, to: superview, attr: .top)
            Constraints.active(item: self, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
            Constraints.active(item: self, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
            Constraints.active(item: self, attr: .height, relatedBy: .lessThanOrEqual, to: nil, attr: .notAnAttribute,
                               constant: 70)
        }
        
        // Text label
        Constraints.active(item: textLabel, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: 16)
        Constraints.active(item: textLabel, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom, constant: -16)
        Constraints.active(item: textLabel, attr: .leading, relatedBy: .equal, to: self, attr: .leading, constant: 20)
        
        if userAction != nil {
            Constraints.active(item: actionButton, attr: .leading, relatedBy: .equal, to: textLabel, attr: .trailing,
                               constant: 16)
            Constraints.active(item: actionButton, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                               constant: -16)
            Constraints.active(item: actionButton, attr: .top, relatedBy: .equal, to: self, attr: .top)
            Constraints.active(item: actionButton, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom)
        } else {
            Constraints.active(item: textLabel, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                               constant: -16)
        }
    }
    
}

// MARK: - Toggle options

extension NoticeView {
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
}
