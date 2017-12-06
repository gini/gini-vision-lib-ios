//
//  QRCodeDetectedPopupView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/6/17.
//

import UIKit

final class QRCodeDetectedPopupView: UIView {
    
    let maxWidth: CGFloat = 375.0
    let padding: (left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) = (20, 20, 20, 20)
    lazy var qrImage: UIImageView = {
        let imageView = UIImageView(image: UIImageNamedPreferred(named: "toolTipCloseButton"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var qrText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "We have found a QR Code!"
        return label
    }()
    lazy var proceedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(self.didTapDoneAction), for: .touchUpInside)
        return button
    }()
    var didTapDone: (() -> Void) = {}
    
    init(superView: UIView) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        
        superView.addSubview(self)
        addSubview(qrImage)
        addSubview(qrText)
        addSubview(proceedButton)
        
        addConstraints(onSuperView: superView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func addConstraints(onSuperView superView: UIView) {
        Contraints.active(item: self, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: maxWidth)
        Contraints.active(item: self, attr: .leading, relatedBy: .greaterThanOrEqual, to: superView, attr: .leading,
                          constant: padding.left)
        Contraints.active(item: self, attr: .trailing, relatedBy: .lessThanOrEqual, to: superView, attr: .trailing,
                          constant: -padding.right)
        Contraints.active(item: self, attr: .top, relatedBy: .equal, to: superView, attr: .top, constant: padding.top)
        
        Contraints.active(item: qrImage, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute, constant: 15)
        Contraints.active(item: qrImage, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute, constant: 15)
        Contraints.active(item: qrImage, attr: .leading, relatedBy: .equal, to: self, attr: .leading,
                          constant: padding.left)
        Contraints.active(item: qrImage, attr: .centerY, relatedBy: .equal, to: qrText, attr: .centerY)
        Contraints.active(item: qrImage, attr: .trailing, relatedBy: .equal, to: qrText, attr: .leading,
                          constant: -padding.right)
        
        Contraints.active(item: qrText, attr: .top, relatedBy: .equal, to: self, attr: .top, constant: padding.top)
        Contraints.active(item: qrText, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -padding.bottom)
        Contraints.active(item: qrText, attr: .trailing, relatedBy: .equal, to: proceedButton, attr: .leading,
                          constant: -padding.right)
        
        Contraints.active(item: proceedButton, attr: .centerY, relatedBy: .equal, to: qrText, attr: .centerY)
        Contraints.active(item: proceedButton, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                          constant: -padding.right)
        
    }
    
    func didTapDoneAction() {
        didTapDone()
    }
}

