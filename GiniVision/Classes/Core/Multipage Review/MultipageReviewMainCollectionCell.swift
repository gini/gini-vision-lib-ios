//
//  MultipageReviewMainCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//

import Foundation

final class MultipageReviewMainCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewMainCollectionCellIdentifier"
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var zoomableScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        return scrollView
    }()
    
    lazy var errorView: NoticeView = {
        let noticeView = NoticeView(text: "",
                                    type: .error,
                                    noticeAction: NoticeAction(title: "", action: {}))
        noticeView.translatesAutoresizingMaskIntoConstraints = false

        noticeView.hide(false, completion: nil)
        return noticeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        zoomableScrollView.addSubview(documentImage)
        addSubview(zoomableScrollView)
        addSubview(errorView)

        addConstraints()
        addDoubleTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    private func addConstraints() {
        Constraints.pin(view: documentImage, toSuperView: zoomableScrollView)
        Constraints.pin(view: zoomableScrollView, toSuperView: self)
        Constraints.pin(view: errorView, toSuperView: self, positions: [.top, .left, .right])
        Constraints.center(view: documentImage, with: zoomableScrollView)
    }
    
    private func addDoubleTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.numberOfTapsRequired = 2
        tapGesture.addTarget(self, action: #selector(doubleTapToZoom))
        zoomableScrollView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func doubleTapToZoom() {
        if zoomableScrollView.zoomScale == 1.0 {
            zoomableScrollView.setZoomScale(2.0, animated: true)
        } else {
            zoomableScrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    func fill(with documentRequest: DocumentRequest, errorAction: @escaping (NoticeActionType) -> Void) {
        documentImage.image = documentRequest.document.previewImage
        
        if let error = documentRequest.error {
            updateErrorView(with: error, errorAction: errorAction)
            errorView.show(false)
        } else {
            errorView.hide(false, completion: nil)
        }
    }
    
    func updateErrorView(with error: Error,
                         errorAction: @escaping (NoticeActionType) -> Void) {
        let buttonTitle: String
        let action: NoticeActionType
        
        switch error {
        case is AnalysisError:
            buttonTitle = NSLocalizedStringPreferred("ginivision.multipagereview.error.retryAction",
                                                     comment: "button title for retry action")
            action = .retry
        default:
            buttonTitle = NSLocalizedStringPreferred("ginivision.multipagereview.error.retakeAction",
                                                     comment: "button title for retake action")
            action = .retake
        }
        
        let message: String
        
        switch error {
        case let error as GiniVisionError:
            message = error.message
        case let error as CustomDocumentValidationError:
            message = error.message
        default:
            message = DocumentValidationError.unknown.message
        }
        
        errorView.textLabel.text = message
        errorView.actionButton.setTitle(buttonTitle, for: .normal)
        errorView.userAction = NoticeAction(title: buttonTitle) {
            errorAction(action)
        }
        errorView.layoutIfNeeded()
    }
    
}

// MARK: - UIScrollViewDelegate

extension MultipageReviewMainCollectionCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return documentImage
    }
}
