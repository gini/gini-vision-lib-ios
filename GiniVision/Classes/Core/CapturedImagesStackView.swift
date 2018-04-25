//
//  CapturedImagesStackView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/25/18.
//

import UIKit

final class CapturedImagesStackView: UIView {
    
    let thumbnailSize = CGSize(width: 40, height: 60)
    private let stackCountCircleSize = CGSize(width: 25, height: 25)

    var count: Int = 0
    
    enum Status {
        case filled(count: Int, lastImage: UIImage), empty
    }
    
    private lazy var multipageReviewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 1
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: -2, height: 2)
        button.addTarget(self, action: #selector(thumbnailButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var multipageReviewBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()
    
    private lazy var stackIndicatorLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Colors.Gini.blue
        return label
    }()
    
    private lazy var stackIndicatorCircleView: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stackCountCircleSize
        view.backgroundColor = .white
        view.layer.cornerRadius = self.stackCountCircleSize.width / 2
        return view
    }()
    
    var didTapImageStackButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(multipageReviewBackgroundView)
        addSubview(multipageReviewButton)
        addSubview(stackIndicatorCircleView)
        stackIndicatorCircleView.addSubview(stackIndicatorLabel)
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(frame:) initializer instead")
    }
    
    func absoluteThumbnailCenter(from view: UIView) -> CGPoint {
        return convert(multipageReviewButton.center, to: view)
    }
    
    func updateStackStatus(to status: Status) {
        switch status {
        case .filled(let count, let lastImage):
            self.count = count
            self.stackIndicatorLabel.text = "\(count)"
            multipageReviewBackgroundView.isHidden = count < 2
            multipageReviewButton.setImage(lastImage, for: .normal)
            isHidden = false
        case .empty:
            multipageReviewBackgroundView.isHidden = true
            multipageReviewButton.setImage(nil, for: .normal)
            isHidden = true
        }
    }
    
    func addImageToStack(image: UIImage) {
        count += 1
        updateStackStatus(to: .filled(count: count, lastImage: image))
    }
    
    fileprivate func addConstraints() {
        Constraints.active(item: multipageReviewButton, attr: .centerY, relatedBy: .equal,
                           to: self, attr: .centerY)
        Constraints.active(item: multipageReviewButton, attr: .centerX, relatedBy: .equal,
                           to: self, attr: .centerX)
        Constraints.active(item: multipageReviewButton, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.height)
        Constraints.active(item: multipageReviewButton, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.width)
        
        Constraints.active(item: multipageReviewBackgroundView, attr: .centerY, relatedBy: .equal,
                           to: multipageReviewButton, attr: .centerY, constant: 3)
        Constraints.active(item: multipageReviewBackgroundView, attr: .centerX, relatedBy: .equal,
                           to: multipageReviewButton, attr: .centerX, constant: -3)
        Constraints.active(item: multipageReviewBackgroundView, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.height)
        Constraints.active(item: multipageReviewBackgroundView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.width)
        
        Constraints.active(item: stackIndicatorCircleView, attr: .trailing, relatedBy: .equal,
                           to: multipageReviewButton, attr: .trailing, constant: stackCountCircleSize.height / 2)
        Constraints.active(item: stackIndicatorCircleView, attr: .top, relatedBy: .equal,
                           to: multipageReviewButton, attr: .top, constant: -stackCountCircleSize.height / 2)
        Constraints.active(item: stackIndicatorCircleView, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.height)
        Constraints.active(item: stackIndicatorCircleView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.width)
        
        Constraints.active(item: stackIndicatorLabel, attr: .centerX, relatedBy: .equal,
                           to: stackIndicatorCircleView, attr: .centerX)
        Constraints.active(item: stackIndicatorLabel, attr: .centerY, relatedBy: .equal,
                           to: stackIndicatorCircleView, attr: .centerY)
        
        Constraints.active(item: stackIndicatorCircleView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.width)
        Constraints.active(item: stackIndicatorCircleView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.width)
    }
    
    @objc func thumbnailButtonAction() {
        didTapImageStackButton?()
    }
}
