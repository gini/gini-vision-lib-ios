//
//  OpenWithTutorialCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/23/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class OpenWithTutorialCollectionCell: UICollectionViewCell {
    
    let padding:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (40, 20, 40, 20)
    let stepIndicatorCircleSize: CGSize = CGSize(width: 30, height: 30)
    let imageHeight: CGFloat = UIDevice.current.isIpad ? 250 : 190
    
    let indicatorToTitleDistance: CGFloat = 30
    let titleToSubtitleDistance: CGFloat = 20
    let subtitleToImageDistance: CGFloat = 40
    
    lazy var stepIndicator: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = GiniConfiguration.sharedConfiguration.stepIndicatorColor
        return label
    }()
    
    lazy var stepIndicatorCircle: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stepIndicatorCircleSize
        view.layer.borderColor = Colors.Gini.pearl.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.stepIndicatorCircleSize.width / 2
        return view
    }()
    
    lazy var stepTitle: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        let textSize: CGFloat = UIDevice.current.isIpad ? 18 : 14
        label.font = label.font.withSize(textSize)
        
        return label
    }()
    
    lazy var stepSubTitle: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        let textSize: CGFloat = UIDevice.current.isIpad ? 16 : 14
        label.font = label.font.withSize(textSize)
        
        return label
    }()
    
    lazy var stepImage: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowRadius = 14
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(stepIndicator)
        addSubview(stepIndicatorCircle)
        addSubview(stepTitle)
        addSubview(stepSubTitle)
        addSubview(stepImage)
        
        addConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstrains() {
        
        // stepIndicator
        ConstraintUtils.addActiveConstraint(item: stepIndicator, attribute: .centerX, relatedBy: .equal, toItem: stepIndicatorCircle, attribute: .centerX, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: stepIndicator, attribute: .centerY, relatedBy: .equal, toItem: stepIndicatorCircle, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        // stepIndicatorCircle
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: stepIndicatorCircleSize.height)
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: stepIndicatorCircleSize.width)
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: padding.top)
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        
        // stepTitle
        ConstraintUtils.addActiveConstraint(item: stepTitle, attribute: .top, relatedBy: .equal, toItem: stepIndicatorCircle, attribute: .bottom, multiplier: 1.0, constant: indicatorToTitleDistance)
        ConstraintUtils.addActiveConstraint(item: stepTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        ConstraintUtils.addActiveConstraint(item: stepTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -padding.right)
        
        // stepSubTitle
        ConstraintUtils.addActiveConstraint(item: stepSubTitle, attribute: .top, relatedBy: .equal, toItem: stepTitle, attribute: .bottom, multiplier: 1.0, constant: titleToSubtitleDistance)
        ConstraintUtils.addActiveConstraint(item: stepSubTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        ConstraintUtils.addActiveConstraint(item: stepSubTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -padding.right)
        
        // stepImage
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .top, relatedBy: .equal, toItem: stepSubTitle, attribute: .bottom, multiplier: 1.0, constant: subtitleToImageDistance)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left, priority: 999)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -padding.right, priority: 999)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -padding.bottom, priority: 999)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: imageHeight)
        
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = superview as? UICollectionView else { return layoutAttributes }
        let isHorizontalLayout = collectionView.frame.width > collectionView.frame.height && UIDevice.current.isIpad
        var maxTextWidth: CGFloat = UIScreen.main.bounds.width - padding.left - padding.right
        
        if isHorizontalLayout {
            maxTextWidth = (UIScreen.main.bounds.width / CGFloat(collectionView.numberOfItems(inSection: 0))) - padding.left - padding.right
        }
        
        let itemSeparations: CGFloat = padding.top + padding.bottom + indicatorToTitleDistance + titleToSubtitleDistance + subtitleToImageDistance
        let itemsHeight = stepIndicatorCircleSize.height +
            imageHeight +
            stepTitle.textHeight(forWidth: maxTextWidth) +
            stepSubTitle.textHeight(forWidth: maxTextWidth)
        
        var height: CGFloat = ceil(itemsHeight + itemSeparations)
        
        if isHorizontalLayout && height < collectionView.frame.height {
            height = collectionView.frame.height
        }
        
        layoutAttributes.frame.size.height = height
        
        return layoutAttributes
    }
    
    public func fillWith(item: OpenWithTutorialStep, at position: Int) {
        stepIndicator.text = String(describing: position + 1)
        stepTitle.text = item.title
        stepSubTitle.text = item.subtitle
        stepImage.image = item.image
    }
}

