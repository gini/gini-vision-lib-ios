//
//  PDFInformationView.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 9/25/17.
//

import Foundation
import UIKit

final class PDFInformationView: UIView {
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    var shadowLayer:CALayer?
    
    enum PDFInformationPosition {
        case top
        case bottom
    }
    
    init(title:String, subtitle:String, textColor:UIColor, textFont:UIFont, backgroundColor:UIColor, superView:UIView?) {
        super.init(frame: .zero)
        guard let superView = superView else { return }
        
        self.backgroundColor = backgroundColor.withAlphaComponent(0.9)
        self.alpha = 0
        
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.textAlignment = .center
        titleLabel.font = textFont.withSize(20.0)
        titleLabel.minimumScaleFactor = 18.0 / 20.0
        titleLabel.adjustsFontSizeToFitWidth = true
        addSubview(titleLabel)
        
        subtitleLabel.text = subtitle
        subtitleLabel.textColor = textColor
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = textFont.withSize(16.0)
        
        addSubview(subtitleLabel)
        
        addInnerShadow(forPosition: .top)
        superView.addSubview(self)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("You should use init(title:subtitle:textColor:background) initializer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        arrangeShadow()
    }
    
    fileprivate func addConstraints() {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        
        ConstraintUtils.addActiveConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: subtitleLabel, attribute: .top, multiplier: 1, constant: -16)
        ConstraintUtils.addActiveConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16)

        ConstraintUtils.addActiveConstraint(item: subtitleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -16)
        ConstraintUtils.addActiveConstraint(item: subtitleLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: subtitleLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -16)

    }
    
    fileprivate func addInnerShadow(forPosition position: PDFInformationPosition) {
        if shadowLayer == nil {
            let size = self.frame.size
            self.clipsToBounds = true
            let layer: CALayer = CALayer()
            layer.backgroundColor = UIColor.lightGray.cgColor
            layer.position = CGPoint(x: size.width / 2, y: -size.height / 2 + 0.5)
            layer.bounds = CGRect(x: 0,y: 0,width: size.width,height: size.height)
            layer.shadowColor = UIColor.darkGray.cgColor
            layer.shadowOffset = CGSize(width: 0.5,height: 0.5)
            layer.shadowOpacity = 0.8
            layer.shadowRadius = 5.0
            shadowLayer = layer
            
            self.layer.addSublayer(layer)
        }
    }
    
    fileprivate func arrangeShadow() {
        let size = self.frame.size
        shadowLayer?.position = CGPoint(x: size.width / 2, y: -size.height / 2 + 0.5)
        shadowLayer?.bounds = CGRect(x: 0,y: 0,width: size.width,height: size.height)
    }
}

// MARK: Show and hide

extension PDFInformationView {
    func show(after seconds:Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: {
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1.0
            }
        })
    }
}



