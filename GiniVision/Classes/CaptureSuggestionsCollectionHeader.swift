//
//  CaptureSuggestionsCollectionHeader.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

final class CaptureSuggestionsCollectionHeader: UICollectionReusableView {
    
    var headerTitle: UILabel = {
        let headerTitle = UILabel()
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.numberOfLines = 0
        headerTitle.font = GiniConfiguration.sharedConfiguration.font.bold.withSize(14)
        return headerTitle
    }()
    var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .lightGray
        return bottomLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(headerTitle)
        addSubview(bottomLine)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .bottom, relatedBy: .equal, toItem: bottomLine, attribute: .top, multiplier: 1.0, constant: -20)
        
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        
    }
}
