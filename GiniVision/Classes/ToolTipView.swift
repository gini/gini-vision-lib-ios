//
//  ToolTipView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/21/17.
//

import Foundation
import UIKit

final class ToolTipView: UIView {
    
    var closeButtonWidth:CGFloat = 20
    var closeButtonHeight:CGFloat = 20
    var maxTextWidth:CGFloat {
        guard let superview = superview else { return 0}
        return superview.frame.width - padding.left - padding.right - margin.left - margin.right - closeButtonWidth - itemSeparation
    }
    var text:String
    var textSize:CGSize = .zero
    var padding:(top:CGFloat, left:CGFloat, right: CGFloat, bottom: CGFloat) = (16, 16, 16, 16)
    var margin:(top:CGFloat, left:CGFloat, right: CGFloat, bottom: CGFloat) = (16, 16, 16, 16)
    var itemSeparation: CGFloat = 16
    
    var textLabel:UILabel = UILabel()
    var closeButton:UIButton = UIButton()
    
    init(text:String, backgroundColor: UIColor = .white, referenceView: UIView, superView:UIView) {
        self.text = text
        super.init(frame: .zero)
        superView.addSubview(self)
        self.textSize = size(forText: text)
        self.backgroundColor = backgroundColor
        
        self.addTextLabel(withText: text)
        self.addCloseButton()
        self.addShadow()
        
        self.frame = computeFrame(referenceView: referenceView, superView: superView)
        self.setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported. Use init(text) instead!")
    }
    
    fileprivate func computeFrame(referenceView: UIView, superView: UIView) -> CGRect {
        let frameHeight = max(textSize.height, closeButtonHeight) + padding.top + padding.bottom
        let frameWidth = textSize.width + closeButtonWidth + padding.left + padding.right + itemSeparation
        let size = CGSize(width: frameWidth, height: frameHeight)
        
        let referenceViewAbsoluteOrigin = referenceView.convert(referenceView.frame.origin, to: superView)
        let origin:CGPoint = CGPoint(x: referenceViewAbsoluteOrigin.x + margin.left , y: referenceViewAbsoluteOrigin.y - size.height - margin.bottom)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate func size(forText text: String) -> CGSize {
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 16)]

        var textSize = text.boundingRect(with: CGSize(width: maxTextWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height + padding.top + padding.bottom)
        
        return textSize
    }
    
    fileprivate func addTextLabel(withText text:String) {
        textLabel.text = text
        textLabel.numberOfLines = 0
        self.addSubview(textLabel)
    }
    
    fileprivate func addCloseButton() {
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        self.addSubview(closeButton)
    }
    
    @objc fileprivate func closeAction() {
        self.removeFromSuperview()
    }
    fileprivate func addShadow() {
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    
    fileprivate func setupConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // textLabel
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: textLabel, attribute: .top, multiplier: 1, constant: -padding.top),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: textLabel, attribute: .bottom, multiplier: 1, constant: padding.bottom),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: textLabel, attribute: .leading, multiplier: 1, constant: -padding.left)
            ])
        
        // closeButton
        self.addConstraints([
            NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: closeButtonWidth),
            NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: closeButtonHeight),
            NSLayoutConstraint(item: closeButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: closeButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: closeButton, attribute: .leading, relatedBy: .equal, toItem: textLabel, attribute: .trailing, multiplier: 1, constant: itemSeparation),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: closeButton, attribute: .trailing, multiplier: 1, constant: padding.right)
            ])
    }
}
