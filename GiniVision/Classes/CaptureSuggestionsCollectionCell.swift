//
//  CaptureSuggestionsCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/25/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation


final class CaptureSuggestionsCollectionCell: UICollectionViewCell {
    
    var suggestionImage: UIImageView = {
        let suggestionImage = UIImageView()
        suggestionImage.translatesAutoresizingMaskIntoConstraints = false
        suggestionImage.contentMode = .scaleAspectFit
        return suggestionImage
    }()
    var suggestionText: UILabel = {
        let suggestionText = UILabel()
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.numberOfLines = 0
        suggestionText.adjustsFontSizeToFitWidth = true
        suggestionText.font = GiniConfiguration.sharedConfiguration.font.regular.withSize(14)
        suggestionText.minimumScaleFactor = 10 / 14
        return suggestionText
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(suggestionImage)
        addSubview(suggestionText)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0, priority: 999)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .trailing, relatedBy: .equal, toItem: suggestionText, attribute: .leading, multiplier: 1.0, constant: -20)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20, priority: 999)
    }
}

