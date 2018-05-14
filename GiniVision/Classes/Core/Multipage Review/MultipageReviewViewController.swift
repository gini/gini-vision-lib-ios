//
//  MultipageReviewViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

@objc public enum ErrorAction: Int {
    case retry, retake
}

public protocol MultipageReviewViewControllerDelegate: class {
    func multipageReview(_ controller: MultipageReviewViewController,
                         didReorder documentRequests: [DocumentRequest])
    func multipageReview(_ controller: MultipageReviewViewController,
                         didRotate documentRequest: DocumentRequest)
    func multipageReview(_ controller: MultipageReviewViewController,
                         didDelete documentRequest: DocumentRequest)
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didSelect errorAction: ErrorAction,
                         for documentRequest: DocumentRequest)
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController)
}

//swiftlint:disable file_length
public final class MultipageReviewViewController: UIViewController {
    
    var documentRequests: [DocumentRequest] 
    public weak var delegate: MultipageReviewViewControllerDelegate?
    let giniConfiguration: GiniConfiguration
    
    // MARK: - UI initialization
    
    lazy var mainCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = Colors.Gini.veryLightGray
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.register(MultipageReviewMainCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewMainCollectionCell.identifier)
        return collection
    }()
    
    var pagesCollectionInsets: UIEdgeInsets {
        let sideInset: CGFloat = (pagesCollection.frame.width -
            MultipageReviewPagesCollectionCell.size.width) / 2
        return UIEdgeInsets(top: 16, left: sideInset, bottom: 16, right: 0)
    }
    
    lazy var pagesCollectionContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.Gini.pearl
        
        return view
    }()
    
    lazy var pagesCollectionTopBorder: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    lazy var pagesCollectionBottomTipLabel: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = NSLocalizedString("ginivision.multipagereview.dragAndDropTip",
                                       bundle: Bundle(for: GiniVision.self),
                                       comment: "drag and drop tip shown below pages collection")
        textView.font = textView.font?.withSize(11)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.backgroundColor = .clear
        return textView
    }()
    
    lazy var pagesCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.clear
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(MultipageReviewPagesCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewPagesCollectionCell.identifier)
        collection.register(MultipageReviewPagesCollectionFooter.self,
                            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                            withReuseIdentifier: MultipageReviewPagesCollectionFooter.identifier)
        return collection
    }()
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: .zero)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.barTintColor = Colors.Gini.pearl
        toolBar.isTranslucent = false
        toolBar.alpha = 0
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: self,
                                            action: nil)
        var items = [self.rotateButton,
                     flexibleSpace,
                     self.deleteButton]
        
        toolBar.setItems(items, animated: false)
        
        return toolBar
    }()
    
    var toolTipView: ToolTipView?
    fileprivate var blurEffect: UIVisualEffectView?
    
    let localizedTitle = NSLocalizedString("ginivision.multipagereview.title",
                                           bundle: Bundle(for: GiniVision.self),
                                           comment: "title with the page indicator")
    
    lazy var rotateButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "rotateImageIcon"),
                                  insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                  action: #selector(rotateImageButtonAction))
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "trashIcon"),
                                  insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                  action: #selector(deleteImageButtonAction))
    }()
    
    fileprivate lazy var pagesCollectionTipLabelHeightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.pagesCollectionBottomTipLabel,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: 0)
        return constraint
    }()
    
    @available(iOS 9.0, *)
    fileprivate lazy var longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                         action: #selector(self.handleLongGesture))
    
    // MARK: - Init
    
    public init(documentRequests: [DocumentRequest], giniConfiguration: GiniConfiguration) {
        self.documentRequests = documentRequests
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(imageDocuments:) has not been implemented")
    }
}

// MARK: - UIViewController
extension MultipageReviewViewController {
    override public func loadView() {
        super.loadView()
        view.addSubview(mainCollection)
        view.addSubview(toolBar)
        view.insertSubview(pagesCollectionContainer, belowSubview: toolBar)
        pagesCollectionContainer.addSubview(pagesCollection)
        pagesCollectionContainer.addSubview(pagesCollectionTopBorder)
        pagesCollectionContainer.addSubview(pagesCollectionBottomTipLabel)
        
        addConstraints()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = mainCollection.backgroundColor
        
        if #available(iOS 9.0, *) {
            longPressGesture.delaysTouchesBegan = true
            pagesCollection.addGestureRecognizer(longPressGesture)
        }
        
        if ToolTipView.shouldShowReorderPagesButtonToolTip {
            createReorderPagesTip()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectLastItem()
        changeReorderTipVisibility(to: documentRequests.count < 2)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showToolbar()
        
        toolTipView?.show {
            self.blurEffect?.alpha = 1
            self.deleteButton.isEnabled = false
            self.rotateButton.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            ToolTipView.shouldShowReorderPagesButtonToolTip = false
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        toolTipView?.arrangeViews()
        blurEffect?.frame = self.mainCollection.frame
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            
            self.toolTipView?.arrangeViews()
            
        })
    }
    
    func selectItem(at position: Int, in section: Int = 0, animated: Bool = true) {
        let indexPath = IndexPath(row: position, section: section)
        self.pagesCollection.selectItem(at: indexPath,
                                        animated: animated,
                                        scrollPosition: .centeredHorizontally)
        self.collectionView(self.pagesCollection, didSelectItemAt: indexPath)
    }
    
    func selectLastItem(animated: Bool = false) {
        let lastPosition = self.documentRequests.count - 1
        selectItem(at: lastPosition, animated: animated)
    }
    
    public func updateCollections(with documentRequests: [DocumentRequest]) {
        self.documentRequests = documentRequests
        self.reloadCollections()
    }
    
    private func reloadCollections() {
        self.mainCollection.reloadData()
        self.pagesCollection.reloadData()
        
        if let currentSelectedItem = pagesCollection.indexPathsForSelectedItems?.first {
            self.selectItem(at: currentSelectedItem.row)
        }
    }
    
}

// MARK: - Private methods

extension MultipageReviewViewController {
    fileprivate func barButtonItem(withImage image: UIImage?,
                                   insets: UIEdgeInsets,
                                   action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.imageEdgeInsets = insets
        button.layer.cornerRadius = 5
        button.tintColor = Colors.Gini.blue
        
        // This is needed since on iOS 9 and below,
        // the buttons are not resized automatically when using autolayout
        if let image = image {
            button.frame = CGRect(origin: .zero, size: image.size)
        }
        
        return UIBarButtonItem(customView: button)
    }
    
    fileprivate func changeTitle(withPage page: Int) {
        title = String(format: localizedTitle, arguments: [page, documentRequests.count])
    }
    
    fileprivate func changeReorderTipVisibility(to hidden: Bool) {
        pagesCollectionBottomTipLabel.isHidden = hidden
        pagesCollectionTipLabelHeightConstraint.constant = hidden ? 0 : 30
    }
    
    @objc @available(iOS 9.0, *)
    fileprivate func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = self.pagesCollection
                .indexPathForItem(at: gesture.location(in: self.pagesCollection)) else {
                    break
            }
            pagesCollection.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let collectionView = gesture.view as? UICollectionView, collectionView == pagesCollection {
                let gesturePosition = gesture.location(in: collectionView)
                let maxY = (collectionView.frame.height / 2) + pagesCollectionInsets.top
                let minY = (collectionView.frame.height / 2) - pagesCollectionInsets.top
                let y = gesturePosition.y > minY ? min(maxY, gesturePosition.y) : minY
                pagesCollection.updateInteractiveMovementTargetPosition(CGPoint(x: gesturePosition.x, y: y))
            }
        case .ended:
            pagesCollection.endInteractiveMovement()
        default:
            pagesCollection.cancelInteractiveMovement()
        }
    }
    
    fileprivate func createReorderPagesTip() {
        blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffect?.alpha = 0
        self.view.addSubview(blurEffect!)
        
        toolTipView = ToolTipView(text: NSLocalizedString("ginivision.multipagereview.reorderContainerTooltipMessage",
                                                          bundle: Bundle(for: GiniVision.self),
                                                          comment: "reorder button tooltip message"),
                                  giniConfiguration: giniConfiguration,
                                  referenceView: pagesCollectionContainer,
                                  superView: view,
                                  position: .above,
                                  distanceToRefView: .zero)
        
        toolTipView?.willDismiss = { [weak self] in
            guard let `self` = self else { return }
            self.blurEffect?.removeFromSuperview()
            self.deleteButton.isEnabled = true
            self.rotateButton.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.toolTipView = nil
        }
    }
    
    fileprivate func showToolbar() {
        UIView.animate(withDuration: AnimationDuration.fast, animations: {
            self.toolBar.alpha = 1
        }, completion: { _ in
            self.pagesCollectionContainer.alpha = 1
        })
    }
    
    fileprivate func addConstraints() {
        // mainCollection
        Constraints.active(item: mainCollection, attr: .bottom, relatedBy: .equal, to: pagesCollectionContainer,
                           attr: .top)
        Constraints.active(item: mainCollection, attr: .top, relatedBy: .equal, to: topLayoutGuide,
                           attr: .bottom)
        Constraints.active(item: mainCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: mainCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // toolBar
        Constraints.active(item: toolBar, attr: .bottom, relatedBy: .equal, to: bottomLayoutGuide,
                           attr: .top)
        Constraints.active(item: toolBar, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: toolBar, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // pagesCollectionContainer
        Constraints.active(item: pagesCollectionContainer, attr: .bottom, relatedBy: .equal, to: toolBar, attr: .top)
        Constraints.active(item: pagesCollectionContainer, attr: .trailing, relatedBy: .equal, to: view,
                           attr: .trailing)
        Constraints.active(item: pagesCollectionContainer, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // pagesCollectionTopBorder
        Constraints.active(item: pagesCollectionTopBorder, attr: .top, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .top)
        Constraints.active(item: pagesCollectionTopBorder, attr: .leading, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .leading)
        Constraints.active(item: pagesCollectionTopBorder, attr: .trailing, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .trailing)
        Constraints.active(item: pagesCollectionTopBorder, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: 0.5)
        
        // pagesCollection
        Constraints.active(item: pagesCollection, attr: .bottom, relatedBy: .equal, to: pagesCollectionBottomTipLabel,
                           attr: .top)
        Constraints.active(item: pagesCollection, attr: .top, relatedBy: .equal, to: pagesCollectionContainer,
                           attr: .top)
        Constraints.active(item: pagesCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: pagesCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        Constraints.active(item: pagesCollection, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: MultipageReviewPagesCollectionCell.size.height +
                            pagesCollectionInsets.top +
                            pagesCollectionInsets.bottom)
        
        // pagesCollectionBottomTipLabel
        Constraints.active(item: pagesCollectionBottomTipLabel, attr: .bottom, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .bottom)
        Constraints.active(constraint: pagesCollectionTipLabelHeightConstraint)
        Constraints.active(item: pagesCollectionBottomTipLabel, attr: .centerX, relatedBy: .equal,
                           to: pagesCollectionContainer, attr: .centerX)
    }
}

// MARK: - Toolbar actions

extension MultipageReviewViewController {
    @objc fileprivate func rotateImageButtonAction() {
        if let currentIndexPath = visibleCell(in: self.mainCollection) {
            guard let imageDocument = documentRequests[currentIndexPath.row].document as? GiniImageDocument else {
                return
            }
            imageDocument.rotatePreviewImage90Degrees()
            mainCollection.reloadItems(at: [currentIndexPath])
            pagesCollection.reloadItems(at: [currentIndexPath])
            selectItem(at: currentIndexPath.row)
            delegate?.multipageReview(self, didRotate: documentRequests[currentIndexPath.row])
        }
    }
    
    @objc fileprivate func deleteImageButtonAction() {
        if let currentIndexPath = visibleCell(in: self.mainCollection) {
            deleteItem(at: currentIndexPath)
        }
    }
    
    public func deleteItem(at indexPath: IndexPath, completion: (() -> Void)? = nil) {
        let documentToDelete = documentRequests[indexPath.row]
        documentRequests.remove(at: indexPath.row)
        mainCollection.deleteItems(at: [indexPath])
        
        pagesCollection.performBatchUpdates({
            self.pagesCollection.deleteItems(at: [indexPath])
        }, completion: { [weak self] _ in
            guard let `self` = self else { return }
            if self.documentRequests.count > 0 {
                if indexPath.row != self.documentRequests.count {
                    var indexes = IndexPath.indexesBetween(indexPath,
                                                           and: IndexPath(row: self.documentRequests.count,
                                                                          section: 0))
                    indexes.append(indexPath)
                    self.pagesCollection.reloadItems(at: indexes)
                }
                
                self.selectItem(at: min(indexPath.row, self.documentRequests.count - 1))
            }
            self.delegate?.multipageReview(self, didDelete: documentToDelete)
            completion?()
        })
    }
}

// MARK: UICollectionViewDataSource

extension MultipageReviewViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.documentRequests.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollection {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewMainCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewMainCollectionCell
            let documentRequest = documentRequests[indexPath.row]
            cell?.fill(with: documentRequest) { action in
                self.delegate?.multipageReview(self, didSelect: action, for: documentRequest)
            }

            return cell!
        } else {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewPagesCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewPagesCollectionCell
            cell?.fill(with: documentRequests[indexPath.row], at: indexPath.row)
            return cell!
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind,
                                              withReuseIdentifier: MultipageReviewPagesCollectionFooter.identifier,
                                              for: indexPath) as? MultipageReviewPagesCollectionFooter
        footer?.trailingConstraint?.constant = -MultipageReviewPagesCollectionFooter.padding(in: collectionView).right
        footer?.didTapAddButton = { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.multipageReviewDidTapAddImage(self)
        }
        return footer!
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               moveItemAt sourceIndexPath: IndexPath,
                               to destinationIndexPath: IndexPath) {
        if collectionView == pagesCollection {
            var indexes = IndexPath.indexesBetween(sourceIndexPath, and: destinationIndexPath)
            indexes.append(sourceIndexPath)
            
            // On iOS < 11 the destinationIndexPath is not reloaded automatically.
            if ProcessInfo().operatingSystemVersion.majorVersion < 11 {
                indexes.append(destinationIndexPath)
            }
            
            let elementMoved = documentRequests.remove(at: sourceIndexPath.row)
            documentRequests.insert(elementMoved, at: destinationIndexPath.row)
            self.mainCollection.reloadData()
            
            // This is needed because this method is called before the dragging animation finishes.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                guard let `self` = self else { return }
                self.pagesCollection.reloadItems(at: indexes)
                self.selectItem(at: destinationIndexPath.row)
                self.delegate?.multipageReview(self, didReorder: self.documentRequests)
            })
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension MultipageReviewViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == mainCollection ?
            collectionView.frame.size :
            MultipageReviewPagesCollectionCell.size
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        guard collectionView == pagesCollection else {
            return .zero
        }
        
        return MultipageReviewPagesCollectionFooter.size(in: collectionView)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == pagesCollection {
            if documentRequests.count > 1 {
                mainCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                pagesCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            changeTitle(withPage: indexPath.row + 1)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionView == mainCollection ? .zero : pagesCollectionInsets
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mainCollection {
            if let indexPath = visibleCell(in: mainCollection) {
                selectItem(at: indexPath.row)
            }
        }
    }
    
    func visibleCell(in collectionView: UICollectionView) -> IndexPath? {
        collectionView.layoutIfNeeded() // It is needed due to a bug in UIKit.
        return collectionView.indexPathsForVisibleItems.first
    }
    
    func visibleMainCollectionImage(from coordinateSpace: UICoordinateSpace) -> (UIImage, CGRect)? {
        let visibleIndex = self.visibleCell(in: mainCollection)
        guard let visibleCellIndex = visibleIndex,
            let cell = collectionView(mainCollection,
                                      cellForItemAt: visibleCellIndex) as? MultipageReviewMainCollectionCell,
            let image = cell.documentImage.image else {
                return nil
        }
        
        cell.documentImage.frame = cell.frame
        return (image, frame(for: cell.documentImage, from: coordinateSpace))
    }
    
    private func frame(for imageView: UIImageView, from coordinateSpace: UICoordinateSpace) -> CGRect {
        guard let image = imageView.image else { return .zero }
        let origin = view.convert(imageView.frame.origin, to: coordinateSpace)
        let imageWidth = imageView.frame.size.height * image.size.width / image.size.height
        let imageOriginX = (imageView.frame.size.width - imageWidth) / 2
        
        return CGRect(origin: CGPoint(x: imageOriginX, y: origin.y),
                      size: CGSize(width: imageWidth, height: imageView.frame.size.height))
    }

}
