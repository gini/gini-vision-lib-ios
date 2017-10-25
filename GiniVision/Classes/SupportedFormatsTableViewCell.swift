//
//  SupportedFormatsTableViewCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/23/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class SupportedFormatsTableViewCell: UITableViewCell {
    
    let imageViewSize = CGSize(width: 12, height: 12)
    let imageBackgroundSize = CGSize(width: 22, height: 22)
    
    lazy var imageBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: self.imageBackgroundSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let textLabel = textLabel {
            textLabel.font = textLabel.font.withSize(14)
            textLabel.numberOfLines = 0
            textLabel.frame.origin = CGPoint(x: textLabel.frame.origin.x + imageBackgroundSize.width - imageViewSize.width, y: textLabel.frame.origin.y)
        }
        
        if let imageView = imageView {
            imageView.tintColor = .white
            imageView.frame = CGRect(origin: CGPoint(x: imageView.frame.origin.x, y: (self.frame.height - imageViewSize.height) / 2), size: imageViewSize)
            contentView.insertSubview(imageBackgroundView, belowSubview: imageView)
            addConstraints()
        }
    }
    
    private func addConstraints() {
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .centerX, relatedBy: .equal, toItem: imageView!, attribute: .centerX, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .centerY, relatedBy: .equal, toItem: imageView!, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22)
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22)
    }
}
