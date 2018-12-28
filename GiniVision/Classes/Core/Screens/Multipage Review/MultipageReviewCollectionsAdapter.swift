//
//  MultipageReviewCollectionsAdapter.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/28/18.
//

import Foundation

protocol MultipageReviewCollectionsAdapterDelegate: class {
    func multipage(_ reviewCollectionsAdapter: MultipageReviewCollectionsAdapter,
                   needReload collectionView: UICollectionView,
                   at indexPath: IndexPath)
}

final class MultipageReviewCollectionsAdapter {
    
    weak var delegate: MultipageReviewCollectionsAdapterDelegate?
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let thumbnailsQueue = DispatchQueue(label: "Thumbnails queue")
    fileprivate var thumbnails: [String: [ThumbnailType: UIImage]] = [:]
    
    enum MultipageCollectionType {
        case main(UICollectionView, (NoticeActionType) -> Void), pages(UICollectionView)
    }
    
    enum ThumbnailType {
        case big, small
        
        var scale: CGFloat {
            switch self {
            case .big:
                return 1.0
            case .small:
                return 1/4
            }
        }
    }
    
    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
    }
    
    func cell(for page: GiniVisionPage,
              in collection: MultipageCollectionType,
              isSelected: Bool,
              at indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collection {
        case .main(let collectionView, let errorAction):
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewMainCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewMainCollectionCell
            setUp(cell: cell!,
                  with: page,
                  in: collectionView,
                  at: indexPath,
                  didTapErrorNotice: errorAction)
            return cell!
        case .pages(let collectionView):
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewPagesCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewPagesCollectionCell
            setUp(cell: cell!, with: page, in: collectionView, at: indexPath, selected: isSelected)
            return cell!
        }
        
    }
}

// MARK: - Cells setup

fileprivate extension MultipageReviewCollectionsAdapter {
    
    // MARK: - MultipageReviewPagesCollectionCell
    
    func setUp(cell: MultipageReviewPagesCollectionCell,
               with page: GiniVisionPage,
               in collectionView: UICollectionView,
               at indexPath: IndexPath,
               selected: Bool) {
        // Thumbnail set
        if let thumbnail = self.thumbnails[page.document.id, default: [:]][.small] {
            cell.documentImage.contentMode = thumbnail.size.width > thumbnail.size.height ?
                .scaleAspectFit :
                .scaleAspectFill
            cell.documentImage.image = thumbnail
        } else {
            cell.documentImage.image = nil
            fetchThumbnailImage(for: page, of: .small, in: collectionView, at: indexPath)
        }
        
        cell.pageIndicatorLabel.text = "\(indexPath.row + 1)"
        cell.pageIndicatorLabel.textColor = giniConfiguration.multipagePageIndicatorColor
        cell.pageSelectedLine.backgroundColor = giniConfiguration.multipagePageSelectedIndicatorColor
        cell.draggableIcon.tintColor = giniConfiguration.multipageDraggableIconColor
        cell.bottomContainer.backgroundColor = giniConfiguration.multipagePageBackgroundColor
        
        // Every time the cell is dequeued, its `isSelected` state is set to default, false.
        cell.pageSelectedLine.alpha = selected ? 1 : 0
        
        if page.isUploaded {
            cell.stateView.update(to: .succeeded)
        } else if page.error != nil {
            cell.stateView.update(to: .failed)
        } else {
            cell.stateView.update(to: .loading)
        }
    }
    
    // MARK: - MultipageReviewMainCollectionCell
    
    func setUp(cell: MultipageReviewMainCollectionCell,
               with page: GiniVisionPage,
               in collectionView: UICollectionView,
               at indexPath: IndexPath,
               didTapErrorNotice action: @escaping (NoticeActionType) -> Void) {
        // Thumbnail set
        if let thumbnail = self.thumbnails[page.document.id, default: [:]][.big] {
            cell.documentImage.image = thumbnail
        } else {
            cell.documentImage.image = nil
            fetchThumbnailImage(for: page, of: .big, in: collectionView, at: indexPath)
        }
                
        if let error = page.error {
            setUpErrorView(in: cell, with: error, didTapErrorNoticeAction: action)
            cell.errorView.show(false)
        } else {
            cell.errorView.hide(false, completion: nil)
        }
    }
    
    func setUpErrorView(in cell: MultipageReviewMainCollectionCell,
                         with error: Error,
                         didTapErrorNoticeAction: @escaping (NoticeActionType) -> Void) {
        let buttonTitle: String
        let action: NoticeActionType
        
        switch error {
        case is AnalysisError:
            buttonTitle = .localized(resource: MultipageReviewStrings.retryActionButton)
            action = .retry
        default:
            buttonTitle = .localized(resource: MultipageReviewStrings.retakeActionButton)
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
        
        cell.errorView.textLabel.text = message
        cell.errorView.actionButton.setTitle(buttonTitle, for: .normal)
        cell.errorView.userAction = NoticeAction(title: buttonTitle) {
            didTapErrorNoticeAction(action)
        }
        cell.errorView.layoutIfNeeded()
    }
}

// MARK: - Thumbnails

fileprivate extension MultipageReviewCollectionsAdapter {
    func fetchThumbnailImage(for page: GiniVisionPage,
                             of type: ThumbnailType,
                             in collectionView: UICollectionView,
                             at indexPath: IndexPath) {
        thumbnailsQueue.async { [weak self] in
            guard let self = self else { return }
            let thumbnail = UIImage.downsample(from: page.document.data,
                                               to: self.targetThumbnailSize(from: page.document.data),
                                               scale: type.scale)
            self.thumbnails[page.document.id, default: [:]][type] = thumbnail
            
            DispatchQueue.main.async {
                self.delegate?.multipage(self, needReload: collectionView, at: indexPath)
            }
        }
    }
    
    func targetThumbnailSize(from imageData: Data, screen: UIScreen = .main) -> CGSize {
        let imageSize = UIImage(data: imageData)?.size ?? .zero
        
        if imageSize.width > (screen.bounds.size.width * 2) {
            let maxWidth = screen.bounds.size.width * 2
            return CGSize(width: maxWidth, height: imageSize.height * maxWidth / imageSize.width)
        } else {
            return imageSize
        }
        
    }
}
