//
//  CameraNotAuthorizedView.swift
//  GiniVision
//
//  Created by Peter Pult on 06/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class CameraNotAuthorizedView: UIView {
    
    // User interface
    fileprivate var label = UILabel()
    fileprivate var button = UIButton()
    fileprivate var imageView = UIImageView()
    fileprivate var contentView = UIView()
    
    // Images
    fileprivate var noCameraImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraNotAuthorizedIcon")
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        // Configure image view
        imageView.image = noCameraImage
        imageView.contentMode = .scaleAspectFit
        
        // Configure label
        label.text = GiniConfiguration.sharedConfiguration.cameraNotAuthorizedText
        label.numberOfLines = 0
        label.textColor = GiniConfiguration.sharedConfiguration.cameraNotAuthorizedTextColor
        label.textAlignment = .center
        label.font = GiniConfiguration.sharedConfiguration.customFont.isEnabled ?
            GiniConfiguration.sharedConfiguration.customFont.thin.withSize(20) :
            GiniConfiguration.sharedConfiguration.cameraNotAuthorizedTextFont
        
        // Configure button
        button.setTitle(GiniConfiguration.sharedConfiguration.cameraNotAuthorizedButtonTitle, for: .normal)
        button.setTitleColor(GiniConfiguration.sharedConfiguration.cameraNotAuthorizedButtonTitleColor, for: .normal)
        button.setTitleColor(GiniConfiguration.sharedConfiguration.cameraNotAuthorizedButtonTitleColor.withAlphaComponent(0.8), for: .highlighted)
        button.titleLabel?.font = GiniConfiguration.sharedConfiguration.customFont.isEnabled ?
            GiniConfiguration.sharedConfiguration.customFont.regular.withSize(20) :
            GiniConfiguration.sharedConfiguration.cameraNotAuthorizedButtonFont
        button.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        // Configure view hierachy
        addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.addSubview(button)
        
        // Add constraints
        addConstraints()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func openSettings(_ sender: AnyObject) {
        UIApplication.shared.openAppSettings()
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self
        
        // Content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: contentView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: superview, attribute: .top, multiplier: 1, constant: 30)
        ConstraintUtils.addActiveConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 5, priority: 999)
        
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 204)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 75)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 75)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 50)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        
        // Text label
        label.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 35)
        ConstraintUtils.addActiveConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 250)
        ConstraintUtils.addActiveConstraint(item: label, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 70)
        
        // Button
        button.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 10)
        ConstraintUtils.addActiveConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: label, attribute: .width, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35)
        ConstraintUtils.addActiveConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
    }
    
}
