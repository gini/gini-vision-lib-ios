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
    
    fileprivate let suggestionIcon: UIImageView
    fileprivate let suggestionText: UILabel
    fileprivate let suggestionContainer: UIView
    fileprivate let suggestionTitle: UILabel
    fileprivate let containerHeight: CGFloat = 135
    fileprivate let suggestionTitleHeight: CGFloat = 20
    fileprivate var itemSeparationConstraint: NSLayoutConstraint = NSLayoutConstraint()
    fileprivate var bottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    fileprivate let repeatInterval: TimeInterval = 5
    fileprivate let superViewBottomLayout: UILayoutSupport
    
    fileprivate let suggestionIconImage = UIImage(named: "analysisSuggestionsIcon",
                                                  in: Bundle(for: GiniVision.self),
                                                  compatibleWith: nil)
    fileprivate var suggestionTexts: [String] = [
        NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self),
                          comment: "First suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self),
                          comment: "Second suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self),
                          comment: "Third suggestion text for analysis screen"),
        NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self),
                          comment: "Forth suggestion text for analysis screen")]
    
    init(superView: UIView, bottomLayout: UILayoutSupport, font: UIFont) {
        suggestionContainer = UIView()
        suggestionTitle = UILabel()
        suggestionText = UILabel()
        superViewBottomLayout = bottomLayout

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
        
        translatesAutoresizingMaskIntoConstraints = false
        suggestionContainer.translatesAutoresizingMaskIntoConstraints = false
        suggestionTitle.translatesAutoresizingMaskIntoConstraints = false
        suggestionIcon.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraints()
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init() initializer")
    }
    
    //swiftlint:disable function_body_length
    fileprivate func addConstraints() {
        guard let superview = superview else { return }
        
        // self
        bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
                                              toItem: superViewBottomLayout, attribute: .top, multiplier: 1,
                                              constant: containerHeight)
        Contraints.active(item: self, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        Contraints.active(item: self, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        Contraints.active(item: self, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: containerHeight)
        Contraints.active(constraint: bottomConstraint)

        // suggestionTitle
        Contraints.active(item: suggestionTitle, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Contraints.active(item: suggestionTitle, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: 8)
        Contraints.active(item: suggestionTitle, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -8, priority: 999)
        Contraints.active(item: suggestionTitle, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: suggestionTitleHeight)

        // suggestionContainer
        itemSeparationConstraint = NSLayoutConstraint(item: suggestionContainer, attribute: .top, relatedBy: .equal,
                                                      toItem: suggestionTitle, attribute: .bottom, multiplier: 1,
                                                      constant: 0)
        Contraints.active(item: suggestionContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: containerHeight - suggestionTitleHeight)
        Contraints.active(constraint: itemSeparationConstraint)
        
        // suggestionIcon
        Contraints.active(item: suggestionIcon, attr: .leading, relatedBy: .equal, to: suggestionContainer,
                          attr: .leading)
        Contraints.active(item: suggestionIcon, attr: .height, relatedBy: .lessThanOrEqual, to: nil,
                          attr: .notAnAttribute, constant: 48)
        Contraints.active(item: suggestionIcon, attr: .width, relatedBy: .equal, to: suggestionIcon, attr: .height)
        Contraints.active(item: suggestionIcon, attr: .centerY, relatedBy: .equal, to: suggestionContainer,
                          attr: .centerY)
        Contraints.active(item: suggestionIcon, attr: .trailing, relatedBy: .equal, to: suggestionText, attr: .leading,
                          constant: -16)
        
        // suggestionText
        Contraints.active(item: suggestionText, attr: .top, relatedBy: .equal, to: suggestionContainer, attr: .top,
                          constant: 16, priority: 999)
        Contraints.active(item: suggestionText, attr: .trailing, relatedBy: .equal, to: suggestionContainer,
                          attr: .trailing, priority: 999)
        Contraints.active(item: suggestionText, attr: .bottom, relatedBy: .equal, to: suggestionContainer,
                          attr: .bottom, constant: -16, priority: 999)
        
        // Center on align to margins depending on device
        if UIDevice.current.isIpad {
            Contraints.active(item: suggestionContainer, attr: .width, relatedBy: .lessThanOrEqual, to: self,
                              attr: .width, multiplier: 0.9)
            Contraints.active(item: suggestionText, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
        } else {
            Contraints.active(item: suggestionContainer, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                              constant: 20)
            Contraints.active(item: suggestionContainer, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                              constant: -20, priority: 999)
        }
    }
}

// MARK: Animations

extension CaptureSuggestionsView {
    
    func start(after seconds: TimeInterval = 4) {
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
    
    fileprivate func changeView(toState state: CaptureSuggestionsState) {
        let delay: TimeInterval
        let nextState: CaptureSuggestionsState
        
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
    
    fileprivate func updatePosition(withState state: CaptureSuggestionsState) {
        if state == .shown {
            self.itemSeparationConstraint.constant = 0
        } else {
            self.itemSeparationConstraint.constant = containerHeight
        }
    }
}
