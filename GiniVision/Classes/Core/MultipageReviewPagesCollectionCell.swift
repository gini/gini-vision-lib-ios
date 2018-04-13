//
//  MultipageReviewPagesCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/1/18.
//

import Foundation

final class MultipageReviewPagesCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewPagesCollectionCellIdentifier"
    static let size = CGSize(width: 84,
                             height: 150 +
                                MultipageReviewPagesCollectionCell.shadowHeight +
                                MultipageReviewPagesCollectionCell.shadowRadius)
    static let shadowHeight: CGFloat = 2
    static let shadowRadius: CGFloat = 1
    let pageIndicatorCircleSize = CGSize(width: 25, height: 25)
    let statusViewSize = CGSize(width: 40, height: 40)
    
    lazy var roundMask: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = Colors.Gini.veryLightGray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var statusView: PageStatusView  = {
        let view = PageStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = self.statusViewSize.width / 2
        
        return view
    }()
    
    lazy var traslucentBackground: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
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
    
    lazy var pageIndicatorLabel: UILabel = {
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
        roundMask.addSubview(traslucentBackground)
        roundMask.addSubview(statusView)
        bottomContainer.addSubview(pageIndicatorLabel)
        bottomContainer.addSubview(pageIndicatorCircle)
        bottomContainer.addSubview(draggableIcon)
        
        addShadow()
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    //swiftlint:disable function_body_length
    fileprivate func addConstraints() {
        // roundMask
        Constraints.active(item: roundMask, attr: .top, relatedBy: .equal, to: self, attr: .top)
        Constraints.active(item: roundMask, attr: .leading, relatedBy: .equal, to: self, attr: .leading)
        Constraints.active(item: roundMask, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing)
        Constraints.active(item: roundMask, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                          constant: -(MultipageReviewPagesCollectionCell.shadowHeight +
                            MultipageReviewPagesCollectionCell.shadowRadius))
        
        // pageIndicator
        Constraints.active(item: pageIndicatorLabel, attr: .centerX, relatedBy: .equal, to: pageIndicatorCircle,
                          attr: .centerX)
        Constraints.active(item: pageIndicatorLabel, attr: .centerY, relatedBy: .equal, to: pageIndicatorCircle,
                          attr: .centerY)
        
        // statusView
        Constraints.active(item: statusView, attr: .centerX, relatedBy: .equal, to: documentImage, attr: .centerX)
        Constraints.active(item: statusView, attr: .centerY, relatedBy: .equal, to: documentImage, attr: .centerY)
        Constraints.active(item: statusView, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: statusViewSize.height)
        Constraints.active(item: statusView, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: statusViewSize.width)

        // pageIndicatorCircle
        Constraints.active(item: pageIndicatorCircle, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: pageIndicatorCircleSize.height)
        Constraints.active(item: pageIndicatorCircle, attr: .width, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: pageIndicatorCircleSize.width)
        Constraints.active(item: pageIndicatorCircle, attr: .top, relatedBy: .equal, to: bottomContainer,
                          attr: .top, constant: 10, priority: 999)
        Constraints.active(item: pageIndicatorCircle, attr: .bottom, relatedBy: .equal, to: bottomContainer,
                          attr: .bottom, constant: -10, priority: 999)
        Constraints.active(item: pageIndicatorCircle, attr: .centerX, relatedBy: .equal, to: bottomContainer,
                          attr: .centerX)
        Constraints.active(item: pageIndicatorCircle, attr: .centerY, relatedBy: .equal, to: bottomContainer,
                          attr: .centerY)
        
        // pageSelectedLine
        Constraints.active(item: pageSelectedLine, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 4)
        Constraints.active(item: pageSelectedLine, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Constraints.active(item: pageSelectedLine, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Constraints.active(item: pageSelectedLine, attr: .bottom, relatedBy: .equal, to: roundMask, attr: .bottom)
        
        // draggableIcon
        Constraints.active(item: draggableIcon, attr: .top, relatedBy: .equal, to: bottomContainer, attr: .top,
                          constant: 16)
        Constraints.active(item: draggableIcon, attr: .bottom, relatedBy: .equal, to: bottomContainer, attr: .bottom,
                          constant: -16)
        Constraints.active(item: draggableIcon, attr: .leading, relatedBy: .equal, to: pageIndicatorCircle,
                           attr: .trailing, constant: 22, priority: 999)
        Constraints.active(item: draggableIcon, attr: .trailing, relatedBy: .equal, to: bottomContainer,
                           attr: .trailing, constant: -11)
        
        // documentImage
        Constraints.active(item: documentImage, attr: .top, relatedBy: .equal, to: roundMask, attr: .top)
        Constraints.active(item: documentImage, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Constraints.active(item: documentImage, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Constraints.active(item: documentImage, attr: .bottom, relatedBy: .equal, to: bottomContainer, attr: .top)
        
        // traslucentBackground
        Constraints.active(item: traslucentBackground, attr: .top, relatedBy: .equal, to: documentImage, attr: .top)
        Constraints.active(item: traslucentBackground, attr: .leading, relatedBy: .equal, to: documentImage,
                           attr: .leading)
        Constraints.active(item: traslucentBackground, attr: .trailing, relatedBy: .equal, to: documentImage,
                           attr: .trailing)
        Constraints.active(item: traslucentBackground, attr: .bottom, relatedBy: .equal, to: documentImage,
                           attr: .bottom)
        
        // bottomContainer
        Constraints.active(item: bottomContainer, attr: .bottom, relatedBy: .equal, to: roundMask, attr: .bottom)
        Constraints.active(item: bottomContainer, attr: .leading, relatedBy: .equal, to: roundMask, attr: .leading)
        Constraints.active(item: bottomContainer, attr: .trailing, relatedBy: .equal, to: roundMask, attr: .trailing)
        Constraints.active(item: bottomContainer, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 46)
    }
    
    fileprivate func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = MultipageReviewPagesCollectionCell.shadowRadius
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0,
                                    height: MultipageReviewPagesCollectionCell.shadowHeight)
    }
    
    func fill(with validatedDocument: ValidatedDocument, at index: Int) {
        if let image = validatedDocument.value.previewImage {
            documentImage.contentMode = image.size.width > image.size.height ?
                .scaleAspectFit :
                .scaleAspectFill
            documentImage.image = image
        }
        pageIndicatorLabel.text = "\(index + 1)"
        
        if index == 0 {
            statusView.update(to: .success)
        } else if index == 1 {
            statusView.update(to: .failure)
        } else {
            statusView.update(to: .loading)
        }
    }
}
