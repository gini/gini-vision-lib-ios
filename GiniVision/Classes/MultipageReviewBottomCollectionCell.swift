//
//  MultipageReviewBottomCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/1/18.
//

import Foundation

final class MultipageReviewBottomCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewBottomCollectionCellIdentifier"
    static let size = CGSize(width: 107,
                             height: 192 +
                                MultipageReviewBottomCollectionCell.shadowHeight +
                                MultipageReviewBottomCollectionCell.shadowRadius)
    static let shadowHeight: CGFloat = 2
    static let shadowRadius: CGFloat = 1
    let pageIndicatorCircleSize = CGSize(width: 25, height: 25)
    
    lazy var roundMask: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var draggableIcon: UIImageView = {
        let image = UIImage(named: "draggablePageIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var bottomContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var pageIndicator: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.Gini.blue
        return label
    }()
    
    lazy var pageIndicatorCircle: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.pageIndicatorCircleSize
        view.layer.borderColor = Colors.Gini.pearl.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.pageIndicatorCircleSize.width / 2
        return view
    }()
    
    lazy var pageSelectedLine: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.Gini.blue
        view.alpha = 0
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            self.pageSelectedLine.alpha = isSelected ? 1 : 0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(roundMask)
        roundMask.addSubview(bottomContainer)
        roundMask.addSubview(pageSelectedLine)
        roundMask.addSubview(documentImage)
        bottomContainer.addSubview(pageIndicator)
        bottomContainer.addSubview(pageIndicatorCircle)
        bottomContainer.addSubview(draggableIcon)
        
        roundMask.layer.cornerRadius = 5.0
        roundMask.layer.masksToBounds = true
        addShadow()
        
        // roundMask
        Contraints.active(item: roundMask, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Contraints.active(item: roundMask, attr: .leading, relatedBy: .equal, to: self, attr: .leading)
        Contraints.active(item: roundMask, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing)
        Contraints.active(item: roundMask, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -(MultipageReviewBottomCollectionCell.shadowHeight +
                            MultipageReviewBottomCollectionCell.shadowRadius))
        
        // pageIndicator
        Contraints.active(item: pageIndicator, attr: .centerX, relatedBy: .equal, to: pageIndicatorCircle,
                          attr: .centerX)
        Contraints.active(item: pageIndicator, attr: .centerY, relatedBy: .equal, to: pageIndicatorCircle,
                          attr: .centerY)
        
        // pageIndicatorCircle
        Contraints.active(item: pageIndicatorCircle, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: pageIndicatorCircleSize.height)
        Contraints.active(item: pageIndicatorCircle, attr: .width, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: pageIndicatorCircleSize.width)
        Contraints.active(item: pageIndicatorCircle, attr: .top, relatedBy: .equal, to: bottomContainer,
                          attr: .top, constant: 10, priority: 999)
        Contraints.active(item: pageIndicatorCircle, attr: .bottom, relatedBy: .equal, to: bottomContainer,
                          attr: .bottom, constant: -10, priority: 999)
        Contraints.active(item: pageIndicatorCircle, attr: .centerX, relatedBy: .equal, to: bottomContainer,
                          attr: .centerX)
        Contraints.active(item: pageIndicatorCircle, attr: .centerY, relatedBy: .equal, to: bottomContainer,
                          attr: .centerY)
        
        // pageSelectedLine
        Contraints.active(item: pageSelectedLine, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 4)
        Contraints.active(item: pageSelectedLine, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Contraints.active(item: pageSelectedLine, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Contraints.active(item: pageSelectedLine, attr: .bottom, relatedBy: .equal, to: roundMask, attr: .bottom)
        
        // draggableIcon
        
        Contraints.active(item: draggableIcon, attr: .top, relatedBy: .equal, to: bottomContainer, attr: .top,
                          constant: 16)
        Contraints.active(item: draggableIcon, attr: .bottom, relatedBy: .equal, to: bottomContainer, attr: .bottom,
                          constant: -16)
        Contraints.active(item: draggableIcon, attr: .leading, relatedBy: .equal, to: pageIndicatorCircle, attr: .trailing,
                          constant: 22)
        Contraints.active(item: draggableIcon, attr: .trailing, relatedBy: .equal, to: bottomContainer, attr: .trailing,
                          constant: -11)
        
        // documentImage
        Contraints.active(item: documentImage, attr: .top, relatedBy: .equal, to: roundMask, attr: .top)
        Contraints.active(item: documentImage, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Contraints.active(item: documentImage, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Contraints.active(item: documentImage, attr: .bottom, relatedBy: .equal, to: bottomContainer, attr: .top)
        
        // bottomContainer
        Contraints.active(item: bottomContainer, attr: .bottom, relatedBy: .equal, to: roundMask, attr: .bottom)
        Contraints.active(item: bottomContainer, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Contraints.active(item: bottomContainer, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Contraints.active(item: bottomContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 46)
    }
    
    fileprivate func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = MultipageReviewBottomCollectionCell.shadowRadius
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0,
                                    height: MultipageReviewBottomCollectionCell.shadowHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
