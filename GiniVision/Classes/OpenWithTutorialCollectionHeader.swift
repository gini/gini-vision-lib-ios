//
//  OpenWithTutorialCollectionHeader.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class OpenWithTutorialCollectionHeader: UICollectionReusableView {
    
    let padding:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (20, 20, 20, 20)
    
    lazy var headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .black
        let textSize: CGFloat = UIDevice.current.isIpad ? 16 : 14
        label.font = label.font.withSize(textSize)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12 / textSize
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = nil
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        headerContainer.addSubview(headerTitle)
        addSubview(headerContainer)
        addSubview(bottomLine)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        ConstraintUtils.addActiveConstraint(item: headerContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: headerContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: headerContainer, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .top, relatedBy: .equal, toItem: headerContainer, attribute: .top, multiplier: 1.0, constant: padding.top)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .leading, relatedBy: .equal, toItem: headerContainer, attribute: .leading, multiplier: 1.0, constant: padding.left)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .trailing, relatedBy: .equal, toItem: headerContainer, attribute: .trailing, multiplier: 1.0, constant: -padding.right)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .bottom, relatedBy: .equal, toItem: headerContainer, attribute: .bottom, multiplier: 1.0, constant: -padding.bottom)
        
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .top, relatedBy: .equal, toItem: headerContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 1)
    }
}

