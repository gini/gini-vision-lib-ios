//
//  CaptureSuggestionView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/26/17.
//

import Foundation


final class CaptureSuggestionsView: UIView {
    
    fileprivate let suggestionIcon:UIImageView
    fileprivate let suggestionText:UILabel
    fileprivate let containerHeight:CGFloat = 75
    fileprivate var bottomConstraint:NSLayoutConstraint = NSLayoutConstraint.init()
    fileprivate let repeatInterval:TimeInterval = 4
    
    
    fileprivate let tip1Icon = UIImageNamedPreferred(named: "cameraCaptureButton")
    
    init(superView: UIView, font:UIFont) {
        suggestionIcon = UIImageView(image: tip1Icon)
        suggestionIcon.contentMode = .scaleAspectFit
        suggestionText = UILabel()
        suggestionText.text = "You should try to avoid taking a picture without any source of light"
        suggestionText.textColor = .white
        suggestionText.font = font.withSize(14)
        suggestionText.numberOfLines = 0
        
        super.init(frame: .zero)
        alpha = 0
        backgroundColor = .red
        
        self.addSubview(suggestionIcon)
        self.addSubview(suggestionText)
        
        superView.addSubview(self)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init() initializer")
    }
    
    fileprivate func addConstraints() {
        guard let superview = superview else { return }

        self.translatesAutoresizingMaskIntoConstraints = false
        suggestionIcon.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        
        bottomConstraint = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)

        ConstraintUtils.addActiveConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(bottomConstraint)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: containerHeight)

        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .width, relatedBy: .equal, toItem: suggestionIcon, attribute: .height, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)

        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .trailing, relatedBy: .equal, toItem: suggestionText, attribute: .leading, multiplier: 1, constant: -8)
        
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -16)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0)

    }
}

// MARK: Show and hide

extension CaptureSuggestionsView {
    
    enum CaptureSuggestionsState {
        case shown
        case hidden
    }
    
    func start() {
        alpha = 1
        changeView(toState: .shown)
    }
    
    fileprivate func changeView(toState state:CaptureSuggestionsState) {
        guard let superview = superview else{ return }
        
        updatePosition(withState: state)
        
        let delay:TimeInterval
        let nextState:CaptureSuggestionsState
        if state == .shown {
            delay = 0
            nextState = .hidden
        } else {
            delay = repeatInterval
            nextState = .shown
        }
        
        UIView.animate(withDuration: 0.5, delay: delay, options: [UIViewAnimationOptions.curveEaseInOut], animations: {
            superview.layoutIfNeeded()
        }, completion: {[weak self] _ in
            guard let `self` = self else { return }
            self.changeView(toState: nextState)
        })
    }
    
    fileprivate func updatePosition(withState state:CaptureSuggestionsState) {
        if state == .shown {
            self.bottomConstraint.constant = 0
        } else {
            self.bottomConstraint.constant = self.containerHeight
        }
    }
}


