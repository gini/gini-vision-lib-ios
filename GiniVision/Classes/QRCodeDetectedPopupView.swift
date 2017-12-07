//
//  QRCodeDetectedPopupView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/6/17.
//

import UIKit

final class QRCodeDetectedPopupView: UIView {
    
    let maxWidth: CGFloat = 375.0
    let margin: (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) = (10, 10, 10, 10)
    let padding: (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) = (10, 10, 10, 10)
    let imageSize: CGSize = CGSize(width: 35, height: 35)
    let hiddingDelay: TimeInterval = 10.0
    var bottomConstraint: NSLayoutConstraint?
    
    lazy var qrImage: UIImageView = {
        let imageView = UIImageView(image: UIImageNamedPreferred(named: "toolTipCloseButton"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var qrText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "We have found a QR Code!"
        label.numberOfLines = 0
        return label
    }()
    lazy var proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Use it!", for: .normal)
        button.addTarget(self, action: #selector(self.didTapDoneAction), for: .touchUpInside)
        return button
    }()
    var didTapDone: (() -> Void) = {}
    
    init(parent: UIView, refView: UIView, document: GiniQRCodeDocument, giniConfiguration: GiniConfiguration) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        addShadow()
        
        parent.insertSubview(self, aboveSubview: refView)

        addSubview(qrImage)
        addSubview(qrText)
        addSubview(proceedButton)
        
        qrImage.image = document.previewImage
        qrText.font = giniConfiguration.font.regular.withSize(14)
        proceedButton.setTitleColor(giniConfiguration.qrCodePopupButtonColor, for: .normal)
        proceedButton.setTitleColor(giniConfiguration.qrCodePopupButtonColor.withAlphaComponent(0.5),
                                    for: .highlighted)
        
        addConstraints(onSuperView: parent, refView: refView)
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func addConstraints(onSuperView superView: UIView, refView: UIView) {
        Contraints.active(item: self, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: maxWidth)
        Contraints.active(item: self, attr: .leading, relatedBy: .greaterThanOrEqual, to: superView, attr: .leading,
                          constant: margin.left)
        Contraints.active(item: self, attr: .trailing, relatedBy: .lessThanOrEqual, to: superView, attr: .trailing,
                          constant: -margin.right)
        Contraints.active(item: self, attr: .centerX, relatedBy: .equal, to: refView, attr: .centerX)
        bottomConstraint = NSLayoutConstraint(item: self,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: refView,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: imageSize.height +
                                                padding.top +
                                                padding.bottom +
                                                margin.bottom)
        Contraints.active(constraint: bottomConstraint!)
        
        Contraints.active(item: qrImage, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: imageSize.width)
        Contraints.active(item: qrImage, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: imageSize.height)
        Contraints.active(item: qrImage, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: padding.left)
        Contraints.active(item: qrImage, attr: .trailing, relatedBy: .equal, to: qrText, attr: .leading,
                          constant: -padding.right)
        Contraints.active(item: qrImage, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: padding.top)
        Contraints.active(item: qrImage, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -padding.bottom)
        
        Contraints.active(item: qrText, attr: .trailing, relatedBy: .lessThanOrEqual, to: proceedButton, attr: .leading,
                          constant: -padding.right)
        Contraints.active(item: qrText, attr: .centerY, relatedBy: .equal, to: qrImage, attr: .centerY)
        
        Contraints.active(item: proceedButton, attr: .centerY, relatedBy: .equal, to: qrImage, attr: .centerY)
        Contraints.active(item: proceedButton, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -padding.right)
        
    }
    
    fileprivate func addShadow() {
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 0.8
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    @objc fileprivate func didTapDoneAction() {
        didTapDone()
    }
}

// MARK: - Animations

extension QRCodeDetectedPopupView {
    func show(after seconds: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let `self` = self, let superview = self.superview else { return }
            self.bottomConstraint?.constant = -self.margin.bottom
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            superview.layoutIfNeeded()
            }, completion: { [weak self] _ in
                guard let `self` = self else { return }
                self.hide(after: self.hiddingDelay)
            })
        })
    }
    
    func hide(after seconds: TimeInterval = 0, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: { [weak self] in
            guard let `self` = self, let superview = self.superview else { return }
            self.bottomConstraint?.constant = self.imageSize.height +
                self.padding.top +
                self.padding.bottom +
                self.margin.bottom
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            superview.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.removeFromSuperview()
                completion?()
            })
        })
    }
}