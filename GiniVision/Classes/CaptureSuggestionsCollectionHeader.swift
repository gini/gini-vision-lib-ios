//
//  CaptureSuggestionsCollectionHeader.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

final class CaptureSuggestionsCollectionHeader: UICollectionReusableView {
    
    static let topContainerHeight: CGFloat = 100
    static let subHeaderHeight: CGFloat = 60
    
    private let topViewIconWidth: CGFloat = 25
    private var leadingTopViewTextConstraint: NSLayoutConstraint?
    private var bottomTopViewContainerConstraint: NSLayoutConstraint?

    var shouldShowTopViewIcon: Bool = true {
        didSet {
            if !shouldShowTopViewIcon {
                topViewIcon.removeFromSuperview()
                leadingTopViewTextConstraint?.isActive = true
            }
        }
    }
    
    var shouldShowSubHeader: Bool = true {
        didSet {
            if !shouldShowSubHeader {
                subHeaderTitle.removeFromSuperview()
                topViewContainerBottomLine.removeFromSuperview()
                bottomTopViewContainerConstraint?.isActive = true
            }
        }
    }
    
    // Views
    lazy var topViewContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    lazy var topViewContainerBottomLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .lightGray
        return line
    }()
    lazy var topViewIcon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = GiniConfiguration.sharedConfiguration.noResultsWarningContainerIconColor
        return icon
    }()
    lazy var topViewText: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.numberOfLines = 0
        text.font = UIFont.boldSystemFont(ofSize: 14)
        return text
    }()
    lazy var subHeaderTitle: UILabel = {
        let subHeaderTitle = UILabel()
        subHeaderTitle.translatesAutoresizingMaskIntoConstraints = false
        subHeaderTitle.numberOfLines = 0
        subHeaderTitle.font = UIFont.boldSystemFont(ofSize: 14)
        return subHeaderTitle
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        topViewContainer.addSubview(topViewContainerBottomLine)
        topViewContainer.addSubview(topViewText)
        topViewContainer.addSubview(topViewIcon)
        addSubview(topViewContainer)
        addSubview(subHeaderTitle)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        // Top view container bottom line
        ConstraintUtils.addActiveConstraint(item: topViewContainerBottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)
        ConstraintUtils.addActiveConstraint(item: topViewContainerBottomLine, attribute: .width, relatedBy: .equal, toItem: topViewContainer, attribute: .width, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: topViewContainerBottomLine, attribute: .top, relatedBy: .equal, toItem: topViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        // Top Container
        ConstraintUtils.addActiveConstraint(item: topViewContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: topViewContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: topViewContainer, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: topViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        bottomTopViewContainerConstraint = NSLayoutConstraint(item: topViewContainer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)

        // Top Icon
        ConstraintUtils.addActiveConstraint(item: topViewIcon, attribute: .top, relatedBy: .equal, toItem: topViewContainer, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: topViewIcon, attribute: .bottom, relatedBy: .equal, toItem: topViewContainer, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: topViewIcon, attribute: .leading, relatedBy: .equal, toItem: topViewContainer, attribute: .leading, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: topViewIcon, attribute: .trailing, relatedBy: .equal, toItem: topViewText, attribute: .leading, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: topViewIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: topViewIconWidth)
        
        // Top text
        ConstraintUtils.addActiveConstraint(item: topViewText, attribute: .top, relatedBy: .equal, toItem: topViewContainer, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: topViewText, attribute: .bottom, relatedBy: .equal, toItem: topViewContainer, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: topViewText, attribute: .trailing, relatedBy: .equal, toItem: topViewContainer, attribute: .trailing, multiplier: 1.0, constant: -16, priority: 999)
        leadingTopViewTextConstraint = NSLayoutConstraint(item: topViewText, attribute: .leading, relatedBy: .equal, toItem: topViewContainer, attribute: .leading, multiplier: 1.0, constant: 16)
        
        // Sub header title
        ConstraintUtils.addActiveConstraint(item: subHeaderTitle, attribute: .top, relatedBy: .equal, toItem: topViewContainerBottomLine, attribute: .bottom, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: subHeaderTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: subHeaderTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20)
        ConstraintUtils.addActiveConstraint(item: subHeaderTitle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        
    }
}

