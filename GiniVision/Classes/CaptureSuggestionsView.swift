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
    fileprivate let suggestionContainer:UIView
    fileprivate let suggestionTitle:UILabel
    fileprivate let containerHeight:CGFloat = 135
    fileprivate let suggestionTitleHeight:CGFloat = 20
    fileprivate var itemSeparationConstraint:NSLayoutConstraint = NSLayoutConstraint()
    fileprivate var bottomConstraint:NSLayoutConstraint = NSLayoutConstraint()
    fileprivate let repeatInterval:TimeInterval = 5
    
    fileprivate let suggestionIconImage = UIImage(named: "analysisSuggestionsIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil)
    fileprivate var suggestionTexts:[String] = [
        NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion text for analysis screen")]
    
    init(superView: UIView, font:UIFont) {
        suggestionContainer = UIView()
        suggestionTitle = UILabel()
        suggestionText = UILabel()

        suggestionIcon = UIImageView(image: suggestionIconImage)
        suggestionIcon.contentMode = .scaleAspectFit
        
        suggestionTitle.textColor = .white
        suggestionTitle.font = font.withSize(16)
        suggestionTitle.numberOfLines = 1
        suggestionTitle.text = "Um schneller Ergebnisse zu erhalten, bitte:"
        suggestionTitle.textAlignment = .center
        suggestionTitle.adjustsFontSizeToFitWidth = true
        suggestionTitle.minimumScaleFactor = 14/16
        
        suggestionText.textColor = .white
        suggestionText.font = font.withSize(16)
        suggestionText.numberOfLines = 0
        suggestionTexts.shuffle()
        suggestionText.text = suggestionTexts.first!
        
        super.init(frame: .zero)
        alpha = 0
        
        suggestionContainer.addSubview(suggestionIcon)
        suggestionContainer.addSubview(suggestionText)
        self.addSubview(suggestionContainer)
        self.addSubview(suggestionTitle)
        superView.addSubview(self)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init() initializer")
    }
    
    fileprivate func addConstraints() {
        guard let superview = superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        suggestionContainer.translatesAutoresizingMaskIntoConstraints = false
        suggestionTitle.translatesAutoresizingMaskIntoConstraints = false
        suggestionIcon.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        
        // self
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: containerHeight)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: containerHeight)
        ConstraintUtils.addActiveConstraint(bottomConstraint)

        // suggestionTitle
        ConstraintUtils.addActiveConstraint(item: suggestionTitle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 8)
        ConstraintUtils.addActiveConstraint(item: suggestionTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -8, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionTitle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: suggestionTitleHeight)

        // suggestionContainer
        itemSeparationConstraint = NSLayoutConstraint(item: suggestionContainer, attribute: .top, relatedBy: .equal, toItem: suggestionTitle, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: containerHeight - suggestionTitleHeight)
        ConstraintUtils.addActiveConstraint(itemSeparationConstraint)
        
        // suggestionIcon
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .leading, relatedBy: .equal, toItem: suggestionContainer, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .width, relatedBy: .equal, toItem: suggestionIcon, attribute: .height, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .centerY, relatedBy: .equal, toItem: suggestionContainer, attribute: .centerY, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionIcon, attribute: .trailing, relatedBy: .equal, toItem: suggestionText, attribute: .leading, multiplier: 1, constant: -16)
        
        // suggestionText
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .top, relatedBy: .equal, toItem: suggestionContainer, attribute: .top, multiplier: 1, constant: 16, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .trailing, relatedBy: .equal, toItem: suggestionContainer, attribute: .trailing, multiplier: 1, constant: 0, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .bottom, relatedBy: .equal, toItem: suggestionContainer, attribute: .bottom, multiplier: 1, constant: -16, priority: 999)
        
        // Center on align to margins depending on device
        if UIDevice.current.isIpad {
            ConstraintUtils.addActiveConstraint(item: suggestionContainer, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 0.9, constant: 0)
            ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        } else {
            ConstraintUtils.addActiveConstraint(item: suggestionContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20)
            ConstraintUtils.addActiveConstraint(item: suggestionContainer, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20, priority: 999)
        }

        layoutIfNeeded()
    }
}

// MARK: Animations

extension CaptureSuggestionsView {
    
    func start(after seconds:TimeInterval = 4) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let `self` = self, let superview = self.superview else { return }
            self.bottomConstraint.constant = 0
            self.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                superview.layoutIfNeeded()
            }, completion: { _ in
                self.changeView(toState: .hidden)
            })
        })
    }
    
    fileprivate func changeView(toState state:CaptureSuggestionsState) {
        let delay:TimeInterval
        let nextState:CaptureSuggestionsState
        
        if state == .shown {
            delay = 0
            nextState = .hidden
            changeSuggestionText()
            suggestionContainer.layoutIfNeeded()
        } else {
            delay = repeatInterval
            nextState = .shown
        }
        
        updatePosition(withState: state)

        UIView.animate(withDuration: 0.5, delay: delay, options: [UIViewAnimationOptions.curveEaseInOut], animations: {
            self.layoutIfNeeded()
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
            self.itemSeparationConstraint.constant = 0
        } else {
            self.itemSeparationConstraint.constant = containerHeight
        }
    }
}


