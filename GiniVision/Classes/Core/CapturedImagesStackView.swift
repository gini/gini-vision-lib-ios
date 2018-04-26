//
//  CapturedImagesStackView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/25/18.
//

import UIKit

final class CapturedImagesStackView: UIView {
    
    let thumbnailSize = CGSize(width: 30, height: 45)
    private let stackCountCircleSize = CGSize(width: 25, height: 25)
    
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
    
    private lazy var capturedImagesStackSubtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Captured"
        label.textAlignment = .center
        label.textColor = .white
        label.font = label.font.withSize(12)

        return label
    }()
    
    var didTapImageStackButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(multipageReviewBackgroundView)
        addSubview(multipageReviewButton)
        addSubview(stackIndicatorCircleView)
        addSubview(capturedImagesStackSubtitleLabel)
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
            stackIndicatorLabel.text = "\(count)"
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
        var count: Int = 0
        if let text = stackIndicatorLabel.text, let currentCount = Int(text) {
            count = currentCount + 1
        } else {
            count += 1
        }
        
        updateStackStatus(to: .filled(count: count, lastImage: image))
    }
    
    fileprivate func addConstraints() {
        // multipageReviewButton
        Constraints.active(item: multipageReviewButton, attr: .centerX, relatedBy: .equal,
                           to: self, attr: .centerX)
        Constraints.active(item: multipageReviewButton, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.height)
        Constraints.active(item: multipageReviewButton, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.width)
        
        // multipageReviewBackgroundView
        Constraints.active(item: multipageReviewBackgroundView, attr: .centerY, relatedBy: .equal,
                           to: multipageReviewButton, attr: .centerY, constant: 3)
        Constraints.active(item: multipageReviewBackgroundView, attr: .centerX, relatedBy: .equal,
                           to: multipageReviewButton, attr: .centerX, constant: -3)
        Constraints.active(item: multipageReviewBackgroundView, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.height)
        Constraints.active(item: multipageReviewBackgroundView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: thumbnailSize.width)
        
        // stackIndicatorCircleView
        Constraints.active(item: stackIndicatorCircleView, attr: .trailing, relatedBy: .equal,
                           to: multipageReviewButton, attr: .trailing, constant: stackCountCircleSize.height / 2)
        Constraints.active(item: stackIndicatorCircleView, attr: .top, relatedBy: .equal,
                           to: multipageReviewButton, attr: .top, constant: -stackCountCircleSize.height / 2)
        Constraints.active(item: stackIndicatorCircleView, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.height)
        Constraints.active(item: stackIndicatorCircleView, attr: .width, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: stackCountCircleSize.width)
        
        // stackIndicatorLabel
        Constraints.active(item: stackIndicatorLabel, attr: .centerX, relatedBy: .equal,
                           to: stackIndicatorCircleView, attr: .centerX)
        Constraints.active(item: stackIndicatorLabel, attr: .centerY, relatedBy: .equal,
                           to: stackIndicatorCircleView, attr: .centerY)
        
        // capturedImagesStackSubtitleLabel
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .bottom, relatedBy: .equal,
                           to: self, attr: .bottom, constant: -10)
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .top, relatedBy: .equal,
                           to: multipageReviewBackgroundView, attr: .bottom, constant: 4)
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .leading, relatedBy: .equal,
                           to: self, attr: .leading)
        Constraints.active(item: capturedImagesStackSubtitleLabel, attr: .trailing, relatedBy: .equal,
                           to: self, attr: .trailing)

    }
    
    @objc func thumbnailButtonAction() {
        didTapImageStackButton?()
    }
}
