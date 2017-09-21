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
    
    var arrowView:UIView
    var textLabel:UILabel
    var closeButton:UIButton
    var tipContainer: UIView
    
    init(text:String, backgroundColor: UIColor = .white, referenceView: UIView, superView:UIView) {
        self.text = text
        self.textLabel = UILabel()
        self.closeButton = UIButton()
        self.arrowView = ToolTipView.arrow(withHeight: 20, width: 20, color: .red)
        self.tipContainer = UIView()

        super.init(frame: .zero)
        superView.addSubview(self)
        self.textSize = size(forText: text)
        self.addTipContainer(backgroundColor: backgroundColor, referenceView: referenceView, superView: superView)
        
        self.addTextLabel(withText: text)
        self.addCloseButton()
        self.addArrow(referenceView:referenceView)
        self.addShadow()
        
        self.frame = computeFrame(referenceView: referenceView, superView: superView)
        self.setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported. Use init(text) instead!")
    }
    
    fileprivate func computeFrame(referenceView: UIView, superView: UIView) -> CGRect {
        let frameHeight = max(textSize.height, closeButtonHeight) + padding.top + padding.bottom + margin.top + margin.bottom
        let frameWidth = textSize.width + closeButtonWidth + padding.left + padding.right + itemSeparation +  margin.left + margin.right
        let size = CGSize(width: frameWidth, height: frameHeight)
        
        let referenceViewAbsoluteOrigin = referenceView.convert(referenceView.frame.origin, to: superView)
        let origin:CGPoint = CGPoint(x: referenceViewAbsoluteOrigin.x, y: referenceViewAbsoluteOrigin.y - size.height)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate func size(forText text: String) -> CGSize {
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 16)]

        var textSize = text.boundingRect(with: CGSize(width: maxTextWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height + padding.top + padding.bottom)
        
        return textSize
    }
    
    fileprivate func addTipContainer(backgroundColor color:UIColor, referenceView: UIView, superView:UIView) {
        self.addSubview(tipContainer)
        self.tipContainer.backgroundColor = color
    }
    
    fileprivate func addTextLabel(withText text:String) {
        textLabel.text = text
        textLabel.numberOfLines = 0
        tipContainer.addSubview(textLabel)
    }
    
    fileprivate func addArrow(referenceView:UIView) {
        arrowView.frame.origin = CGPoint(x: 0, y: self.frame.height)
        self.addSubview(arrowView)
    }
    
    fileprivate func addCloseButton() {
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        tipContainer.addSubview(closeButton)
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
        tipContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // tipContainer
        self.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: tipContainer, attribute: .top, multiplier: 1, constant: -margin.top),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: tipContainer, attribute: .bottom, multiplier: 1, constant: margin.bottom),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: tipContainer, attribute: .leading, multiplier: 1, constant: -margin.left),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: tipContainer, attribute: .trailing, multiplier: 1, constant: margin.right)
            ])
        
        // textLabel
        self.addConstraints([
            NSLayoutConstraint(item: tipContainer, attribute: .top, relatedBy: .equal, toItem: textLabel, attribute: .top, multiplier: 1, constant: -padding.top),
            NSLayoutConstraint(item: tipContainer, attribute: .bottom, relatedBy: .equal, toItem: textLabel, attribute: .bottom, multiplier: 1, constant: padding.bottom),
            NSLayoutConstraint(item: tipContainer, attribute: .leading, relatedBy: .equal, toItem: textLabel, attribute: .leading, multiplier: 1, constant: -padding.left)
            ])
        
        // closeButton
        self.addConstraints([
            NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: closeButtonWidth),
            NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: closeButtonHeight),
            NSLayoutConstraint(item: closeButton, attribute: .centerX, relatedBy: .equal, toItem: tipContainer, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: closeButton, attribute: .centerY, relatedBy: .equal, toItem: tipContainer, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: closeButton, attribute: .leading, relatedBy: .equal, toItem: textLabel, attribute: .trailing, multiplier: 1, constant: itemSeparation),
            NSLayoutConstraint(item: tipContainer, attribute: .trailing, relatedBy: .equal, toItem: closeButton, attribute: .trailing, multiplier: 1, constant: padding.right)
            ])
        self.tipContainer.setNeedsLayout()
    }
    
    static func arrow(withHeight height:CGFloat, width:CGFloat, color:UIColor) -> UIView {

        let arrowView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        arrowView.backgroundColor = color
        
        // Get Height and Width
        let layerHeight = height
        let layerWidth = width
        
        // Create Path
        let bezierPath = UIBezierPath()
        
        // Draw Points
        bezierPath.move(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth / 2, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.close()
        
        // Mask to Path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        arrowView.layer.mask = shapeLayer
        return arrowView
    }
}
