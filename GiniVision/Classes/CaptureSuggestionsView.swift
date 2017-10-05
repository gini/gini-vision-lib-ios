//
//  CaptureSuggestionView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/26/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation


final class CaptureSuggestionsView: UIView {
    
    fileprivate enum CaptureSuggestionsState {
        case shown
        case hidden
    }
    
    fileprivate let suggestionIcon:UIImageView
    fileprivate let suggestionText:UILabel
    fileprivate let containerHeight:CGFloat = 115
    fileprivate var bottomConstraint:NSLayoutConstraint = NSLayoutConstraint.init()
    fileprivate var startDelay:TimeInterval = 4
    fileprivate let repeatInterval:TimeInterval = 5
    
    fileprivate let suggestionIconImage = UIImage(named: "analysisSuggestionsIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil)
    fileprivate var suggestionTexts:[String] = [
        NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion text for analysis screen")]
    
    init(superView: UIView, font:UIFont) {
        suggestionIcon = UIImageView(image: suggestionIconImage)
        suggestionIcon.contentMode = .scaleAspectFit
        
        suggestionText = UILabel()
        suggestionText.textColor = .white
        suggestionText.font = font.withSize(16)
        suggestionText.numberOfLines = 0
        suggestionTexts.shuffle()
        suggestionText.text = suggestionTexts.first!
        
        super.init(frame: .zero)
        alpha = 0
        
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
        
        // self
        bottomConstraint = NSLayoutConstraint.init(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: containerHeight)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(bottomConstraint)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: containerHeight)
        
        // suggestionIcon
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .width, relatedBy: .equal, toItem: suggestionIcon, attribute: .height, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .centerY, relatedBy: .equal, toItem: suggestionText, attribute: .centerY, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .trailing, relatedBy: .equal, toItem: suggestionText, attribute: .leading, multiplier: 1, constant: -16)
        
        // suggestionText
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -40)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        
        layoutIfNeeded()
    }
}

// MARK: Animations

extension CaptureSuggestionsView {
    
    func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay, execute: { [weak self] in
            guard let `self` = self else { return }
            self.alpha = 1
            self.changeView(toState: .shown)
        })
    }
    
    fileprivate func changeView(toState state:CaptureSuggestionsState) {
        guard let superview = superview else { return }
        let delay:TimeInterval
        let nextState:CaptureSuggestionsState
        
        if state == .shown {
            delay = 0
            nextState = .hidden
            changeSuggestionText()
        } else {
            delay = repeatInterval
            nextState = .shown
        }
        
        updatePosition(withState: state)

        UIView.animate(withDuration: 0.5, delay: delay, options: [UIViewAnimationOptions.curveEaseInOut], animations: {
            superview.layoutIfNeeded()
        }, completion: {[weak self] _ in
            guard let `self` = self else { return }
            self.changeView(toState: nextState)
        })
    }
    
    fileprivate func changeSuggestionText() {
        if let currentText = suggestionText.text, let currentIndex = suggestionTexts.index(of: currentText) {
            let nextIndex: Int
            if suggestionTexts.index(after: currentIndex) < suggestionTexts.endIndex {
                nextIndex = suggestionTexts.index(after: currentIndex)
            } else {
                nextIndex = 0
            }
            suggestionText.text = suggestionTexts[nextIndex]
        }
    }
    
    fileprivate func updatePosition(withState state:CaptureSuggestionsState) {
        if state == .shown {
            self.bottomConstraint.constant = 0
        } else {
            self.bottomConstraint.constant = self.containerHeight
        }
    }
}


