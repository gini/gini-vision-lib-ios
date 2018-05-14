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
    static let defaultPadding: CGFloat = 10
    
    fileprivate static let contentSize = MultipageReviewPagesCollectionCell.size
    var trailingConstraint: NSLayoutConstraint?
    
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
        label.text = NSLocalizedString("ginivision.multipagereview.addButtonLabel",
                                       bundle: Bundle(for: GiniVision.self),
                                       comment: "label shown below add button")
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
    
    class func size(in collectionView: UICollectionView) -> CGSize {
        let padding = self.padding(in: collectionView)
        let height = MultipageReviewPagesCollectionFooter.contentSize.height +
            padding.top +
            padding.bottom
        let width = MultipageReviewPagesCollectionFooter.contentSize.width +
            padding.left +
            padding.right
        
        return CGSize(width: width, height: height)
    }
    
    class func padding(in collectionView: UICollectionView? = nil) -> UIEdgeInsets {
        var rightPadding: CGFloat = defaultPadding
        if let collection = collectionView {
            rightPadding = ((collection.frame.width -
                MultipageReviewPagesCollectionCell.size.width) / 2)
        }
        
        return UIEdgeInsets(top: defaultPadding, left: defaultPadding, bottom: defaultPadding, right: rightPadding)
    }
}

// MARK: - Private methods

extension MultipageReviewPagesCollectionFooter {
    
    @objc fileprivate func addImageButtonAction() {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator().impactOccurred()
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
                           constant: MultipageReviewPagesCollectionFooter.contentSize.height)
        Constraints.active(item: roundMask, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: MultipageReviewPagesCollectionFooter.contentSize.width)
        Constraints.active(item: roundMask, attr: .centerX, relatedBy: .equal, to: self, attr: .centerX)
        Constraints.active(item: roundMask, attr: .centerY, relatedBy: .equal, to: self, attr: .centerY)
        
        // addButton
        Constraints.active(item: addButton, attr: .centerX, relatedBy: .equal, to: roundMask, attr: .centerX)
        Constraints.active(item: addButton, attr: .centerY, relatedBy: .lessThanOrEqual, to: roundMask,
                           attr: .centerY, priority: 999)
        Constraints.active(item: addButton, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: 60)
        Constraints.active(item: addButton, attr: .width, relatedBy: .equal, to: addButton, attr: .height)
        Constraints.active(item: addButton, attr: .top, relatedBy: .greaterThanOrEqual, to: roundMask,
                           attr: .top, priority: 750)
        
        // addLabel
        Constraints.active(item: addLabel, attr: .centerX, relatedBy: .equal, to: addButton, attr: .centerX)
        Constraints.active(item: addLabel, attr: .top, relatedBy: .equal, to: addButton, attr: .bottom,
                           constant: MultipageReviewPagesCollectionFooter.padding().top)
        Constraints.active(item: addLabel, attr: .bottom, relatedBy: .lessThanOrEqual, to: roundMask, attr: .bottom,
                           constant: -MultipageReviewPagesCollectionFooter.padding().bottom)
        Constraints.active(item: addLabel, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading,
                           constant: MultipageReviewPagesCollectionFooter.padding().left)
        
        // Since it is not possible to add an inset to the footer, but only to the section
        // (header and footer are not part of the section), we add a right inset dynamically through a
        // constraint in our round container view (roundMask).
        trailingConstraint = NSLayoutConstraint(item: roundMask,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: self,
                                                attribute: .trailing,
                                                multiplier: 1.0,
                                                constant: -MultipageReviewPagesCollectionFooter.padding().right)
        Constraints.active(constraint: trailingConstraint!)
    }
}
