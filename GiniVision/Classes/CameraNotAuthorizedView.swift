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
    
    init(giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration) {
        super.init(frame: CGRect.zero)
        
        // Configure image view
        imageView.image = noCameraImage
        imageView.contentMode = .scaleAspectFit
        
        // Configure label
        label.text = giniConfiguration.cameraNotAuthorizedText
        label.numberOfLines = 0
        label.textColor = giniConfiguration.cameraNotAuthorizedTextColor
        label.textAlignment = .center
        label.font = giniConfiguration.customFont.isEnabled ?
            giniConfiguration.customFont.thin.withSize(20) :
            giniConfiguration.cameraNotAuthorizedTextFont
            
        
        // Configure button
        button.setTitle(giniConfiguration.cameraNotAuthorizedButtonTitle, for: .normal)
        button.setTitleColor(giniConfiguration.cameraNotAuthorizedButtonTitleColor, for: .normal)
        button.setTitleColor(giniConfiguration.cameraNotAuthorizedButtonTitleColor.withAlphaComponent(0.8),
                             for: .highlighted)
        button.titleLabel?.font = giniConfiguration.customFont.isEnabled ?
            giniConfiguration.customFont.regular.withSize(20) :
            giniConfiguration.cameraNotAuthorizedButtonFont

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
        Contraints.active(item: contentView, attr: .top, relatedBy: .greaterThanOrEqual, to: superview, attr: .top,
                          constant: 30)
        Contraints.active(item: contentView, attr: .centerX, relatedBy: .equal, to: superview, attr: .centerX)
        Contraints.active(item: contentView, attr: .centerY, relatedBy: .equal, to: superview, attr: .centerY,
                          constant: 5, priority: 999)
        
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: imageView, attr: .top, relatedBy: .equal, to: contentView, attr: .top)
        Contraints.active(item: imageView, attr: .width, relatedBy: .lessThanOrEqual, to: nil, attr: .width,
                          constant: 204)
        Contraints.active(item: imageView, attr: .width, relatedBy: .greaterThanOrEqual, to: nil, attr: .width,
                          constant: 75)
        Contraints.active(item: imageView, attr: .height, relatedBy: .lessThanOrEqual, to: nil, attr: .height,
                          constant: 75)
        Contraints.active(item: imageView, attr: .height, relatedBy: .greaterThanOrEqual, to: nil, attr: .height,
                          constant: 50)
        Contraints.active(item: imageView, attr: .centerX, relatedBy: .equal, to: contentView, attr: .centerX)
        
        // Text label
        label.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: label, attr: .top, relatedBy: .equal, to: imageView, attr: .bottom, constant: 35)
        Contraints.active(item: label, attr: .trailing, relatedBy: .equal, to: contentView, attr: .trailing)
        Contraints.active(item: label, attr: .leading, relatedBy: .equal, to: contentView, attr: .leading)
        Contraints.active(item: label, attr: .width, relatedBy: .equal, to: nil, attr: .width, constant: 250)
        Contraints.active(item: label, attr: .height, relatedBy: .greaterThanOrEqual, to: nil, attr: .height,
                          constant: 70)
        
        // Button
        button.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: button, attr: .top, relatedBy: .equal, to: label, attr: .bottom, constant: 10)
        Contraints.active(item: button, attr: .bottom, relatedBy: .equal, to: contentView, attr: .bottom)
        Contraints.active(item: button, attr: .width, relatedBy: .equal, to: label, attr: .width)
        Contraints.active(item: button, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 35)
        Contraints.active(item: button, attr: .centerX, relatedBy: .equal, to: contentView, attr: .centerX)
    }
    
}
