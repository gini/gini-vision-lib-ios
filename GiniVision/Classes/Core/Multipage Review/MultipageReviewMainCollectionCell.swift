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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        zoomableScrollView.addSubview(documentImage)
        addSubview(zoomableScrollView)
        addConstraints()
        addDoubleTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
    private func addConstraints() {
        Constraints.pin(view: documentImage, toSuperView: zoomableScrollView)
        Constraints.pin(view: zoomableScrollView, toSuperView: self)
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
    
    func fill(with documentRequest: DocumentRequest, errorAction: @escaping () -> Void) {
        documentImage.image = documentRequest.document.previewImage
        
        let currentNoticeView = subviews
            .compactMap { $0 as? NoticeView }
            .first
        
        if let error = documentRequest.error {
            showErrorView(with: currentNoticeView, error: error, errorAction: errorAction)
        } else {
            currentNoticeView?.hide(false, completion: nil)
        }
    }
    
    func showErrorView(with currentNoticeView: NoticeView?, error: Error, errorAction: @escaping () -> Void) {
        let newNoticeView = noticeView(with: error, errorAction: errorAction)
        
        if let currentNoticeView = currentNoticeView {
            currentNoticeView.hide(completion: {
                self.addSubview(newNoticeView)
                newNoticeView.show(false)
            })
        } else {
            self.addSubview(newNoticeView)
            newNoticeView.show(false)
        }
    }
    
    func noticeView(with error: Error,
                    errorAction: @escaping () -> Void) -> NoticeView {
        let buttonTitle: String
        
        switch error {
        case is DocumentValidationError:
            buttonTitle = "Retake"
        default:
            buttonTitle = "Retry"
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
        
        return NoticeView(giniConfiguration: .shared,
                          text: message,
                          type: .error,
                          noticeAction: NoticeAction(title: buttonTitle, action: errorAction))
        
    }
    
}

// MARK: - UIScrollViewDelegate

extension MultipageReviewMainCollectionCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return documentImage
    }
}
