//
//  MultipageReviewPagesCollectionFooter.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/26/18.
//

import Foundation

final class MultipageReviewPagesCollectionFooter: UICollectionReusableView {
    
    static let identifier = "MultipageReviewPagesCollectionFooterIdentifier"
    var didTapAddButton: (() -> Void)?
    fileprivate lazy var roundMask: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .gray
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        return view
    }()
    fileprivate lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImageNamedPreferred(named: "addCircleIcon"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(addImageButtonAction), for: .touchUpInside)
        return button
    }()
    fileprivate lazy var addLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Add new page for this invoice"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(roundMask)
        roundMask.addSubview(addButton)
        roundMask.addSubview(addLabel)
        
        addInnerShadow()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private methods

extension MultipageReviewPagesCollectionFooter {
    
    @objc fileprivate func addImageButtonAction() {
        if #available(iOS 10.0, *) {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        didTapAddButton?()
    }
    
    fileprivate func addInnerShadow() {
        let innerShadow = CALayer()
        innerShadow.frame = bounds

        let path = UIBezierPath(rect: innerShadow.bounds.insetBy(dx: -3, dy: -3))
        let cutout = UIBezierPath(rect: innerShadow.bounds).reversing()
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true

        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize.zero
        innerShadow.shadowOpacity = 0.5
        innerShadow.shadowRadius = 3

        roundMask.layer.addSublayer(innerShadow)
    }
    
    fileprivate func addConstraints() {
        // roundMask
        Constraints.active(item: roundMask, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: MultipageReviewPagesCollectionCell.size.height)
        Constraints.active(item: roundMask, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: MultipageReviewPagesCollectionCell.size.width)
        Constraints.active(item: roundMask, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
        Constraints.active(item: roundMask, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY)
        Constraints.active(item: roundMask, attr: .centerX, relatedBy: .equal, to: addButton, attr: .centerX)
        Constraints.active(item: roundMask, attr: .centerY, relatedBy: .equal, to: addButton, attr: .centerY)
        Constraints.active(item: addLabel, attr: .centerX, relatedBy: .equal, to: addButton, attr: .centerX)
        Constraints.active(item: addLabel, attr: .top, relatedBy: .equal, to: addButton, attr: .bottom, constant: 10)
        Constraints.active(item: addLabel, attr: .leading, relatedBy: .equal, to: self, attr: .leading, constant: 10)
        Constraints.active(item: addLabel, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing, constant: -10)
    }
}
