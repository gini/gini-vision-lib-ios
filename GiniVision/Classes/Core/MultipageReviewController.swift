//
//  MultipageReviewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

//swiftlint:disable file_length
public final class MultipageReviewController: UIViewController {
    
    fileprivate var imageDocuments: [GiniImageDocument]
    var didUpdateDocuments: (([GiniImageDocument]) -> Void)?

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
    
    var bottomCollectionInsets: UIEdgeInsets {
        let sideInset: CGFloat = (bottomCollection.frame.width -
            MultipageReviewBottomCollectionCell.size.width) / 2
        return UIEdgeInsets(top: 16, left: sideInset, bottom: 16, right: sideInset)
    }
    
    lazy var bottomCollectionContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.Gini.pearl
        view.alpha = 0
        
        return view
    }()
    
    lazy var bottomCollectionTopBorder: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        
        return view
    }()
    
    lazy var bottomCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.clear
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(MultipageReviewBottomCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewBottomCollectionCell.identifier)
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
        if #available(iOS 9.0, *) {
            items.insert(self.reorderButton, at: 2)
            items.insert(flexibleSpace, at: 3)
        }
        toolBar.setItems(items, animated: false)
        
        return toolBar
    }()
    
    lazy var rotateButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "rotateImageIcon"),
                                  insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                  action: #selector(rotateSelectedImage))
    }()
    
    lazy var reorderButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "reorderPagesIcon"),
                                  insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4),
                                  action: #selector(toggleReorder))
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "trashIcon"),
                                  insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                  action: #selector(deleteSelectedImage))
    }()
    
    fileprivate lazy var bottomCollectionContainerConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self.bottomCollectionContainer,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: self.toolBar,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: 0)
        constraint.priority = 999
        return constraint
    }()
    
    fileprivate lazy var topCollectionContainerConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.bottomCollectionContainer,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: self.toolBar,
                                  attribute: .top,
                                  multiplier: 1.0,
                                  constant: 0)
    }()
    
    @available(iOS 9.0, *)
    fileprivate lazy var longPressGesture = UILongPressGestureRecognizer(target: self,
                                                                         action: #selector(self.handleLongGesture))
    
    // MARK: - Init
    
    public init(imageDocuments: [GiniImageDocument]) {
        self.imageDocuments = imageDocuments
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(imageDocuments:) has not been implemented")
    }
}

// MARK: - UIViewController
extension MultipageReviewController {
    override public func loadView() {
        super.loadView()
        view.addSubview(mainCollection)
        view.addSubview(toolBar)
        view.insertSubview(bottomCollectionContainer, belowSubview: toolBar)
        bottomCollectionContainer.addSubview(bottomCollection)
        bottomCollectionContainer.addSubview(bottomCollectionTopBorder)
        
        addConstraints()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        selectItem(at: 0)
        view.backgroundColor = mainCollection.backgroundColor
        if #available(iOS 9.0, *) {
            longPressGesture.delaysTouchesBegan = true
            bottomCollection.addGestureRecognizer(longPressGesture)
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: AnimationDuration.fast, animations: {
            self.toolBar.alpha = 1
        }, completion: { _ in
            self.bottomCollectionContainer.alpha = 1
        })
    }
    
    func selectItem(at position: Int, in section: Int = 0) {
        let indexPath = IndexPath(row: position, section: section)
        self.bottomCollection.selectItem(at: indexPath,
                                         animated: true,
                                         scrollPosition: .centeredHorizontally)
        self.collectionView(self.bottomCollection, didSelectItemAt: indexPath)
    }

}

// MARK: - Private methods

extension MultipageReviewController {
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
        title = "\(page) of \(imageDocuments.count)"
    }
    
    fileprivate func changeReorderButtonState(toActive activate: Bool) {
        if activate {
            reorderButton.customView?.layer.backgroundColor = Colors.Gini.blue.cgColor
            reorderButton.customView?.tintColor = .white
        } else {
            reorderButton.customView?.layer.backgroundColor = nil
            reorderButton.customView?.tintColor = Colors.Gini.blue
        }
    }
    
    @objc @available(iOS 9.0, *)
    fileprivate func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = self.bottomCollection
                .indexPathForItem(at: gesture.location(in: self.bottomCollection)) else {
                    break
            }
            bottomCollection.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            if let collectionView = gesture.view as? UICollectionView, collectionView == bottomCollection {
                let gesturePosition = gesture.location(in: collectionView)
                let maxY = (collectionView.frame.height / 2) + bottomCollectionInsets.top
                let minY = (collectionView.frame.height / 2) - bottomCollectionInsets.top
                let y = gesturePosition.y > minY ? min(maxY, gesturePosition.y) : minY
                bottomCollection.updateInteractiveMovementTargetPosition(CGPoint(x: gesturePosition.x, y: y))
            }
        case .ended:
            bottomCollection.endInteractiveMovement()
        default:
            bottomCollection.cancelInteractiveMovement()
        }
    }
    
    fileprivate func addConstraints() {
        // mainCollection
        Constraints.active(item: mainCollection, attr: .bottom, relatedBy: .equal, to: bottomCollectionContainer,
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
        
        // bottomCollectionContainer
        Constraints.active(constraint: topCollectionContainerConstraint)
        Constraints.active(item: bottomCollectionContainer, attr: .trailing, relatedBy: .equal, to: view,
                          attr: .trailing)
        Constraints.active(item: bottomCollectionContainer, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // bottomCollectionTopBorder
        Constraints.active(item: bottomCollectionTopBorder, attr: .top, relatedBy: .equal,
                           to: bottomCollectionContainer, attr: .top)
        Constraints.active(item: bottomCollectionTopBorder, attr: .leading, relatedBy: .equal,
                          to: bottomCollectionContainer, attr: .leading)
        Constraints.active(item: bottomCollectionTopBorder, attr: .trailing, relatedBy: .equal,
                          to: bottomCollectionContainer, attr: .trailing)
        Constraints.active(item: bottomCollectionTopBorder, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: 0.5)
        
        // bottomCollection
        Constraints.active(item: bottomCollection, attr: .bottom, relatedBy: .equal, to: bottomCollectionContainer,
                          attr: .bottom)
        Constraints.active(item: bottomCollection, attr: .top, relatedBy: .equal, to: bottomCollectionContainer,
                          attr: .top)
        Constraints.active(item: bottomCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Constraints.active(item: bottomCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        Constraints.active(item: bottomCollection, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: MultipageReviewBottomCollectionCell.size.height +
                            bottomCollectionInsets.top +
                            bottomCollectionInsets.bottom)
    }
}

// MARK: - Toolbar actions

extension MultipageReviewController {
    @objc fileprivate func rotateSelectedImage() {
        if let currentIndexPath = visibleCell(in: self.mainCollection) {
            imageDocuments[currentIndexPath.row].rotatePreviewImage(degrees: 90)
            mainCollection.reloadItems(at: [currentIndexPath])
            bottomCollection.reloadItems(at: [currentIndexPath])
            selectItem(at: currentIndexPath.row)
            didUpdateDocuments?(self.imageDocuments)
        }
    }
    
    @objc fileprivate func deleteSelectedImage() {
        if let currentIndexPath = visibleCell(in: self.mainCollection) {
            imageDocuments.remove(at: currentIndexPath.row)
            mainCollection.deleteItems(at: [currentIndexPath])
            
            bottomCollection.performBatchUpdates({
                self.bottomCollection.deleteItems(at: [currentIndexPath])
            }, completion: { [weak self] _ in
                guard let `self` = self else { return }
                if self.imageDocuments.count > 0 {
                    if currentIndexPath.row != self.imageDocuments.count {
                        var indexes = IndexPath.indexesBetween(currentIndexPath,
                                                               and: IndexPath(row: self.imageDocuments.count,
                                                                              section: 0))
                        indexes.append(currentIndexPath)
                        self.bottomCollection.reloadItems(at: indexes)
                    }
                    
                    self.selectItem(at: min(currentIndexPath.row, self.imageDocuments.count - 1))
                }
                self.didUpdateDocuments?(self.imageDocuments)
            })
        }
    }
    
    @objc fileprivate func toggleReorder() {
        let hide = self.bottomCollectionContainerConstraint.isActive
        self.topCollectionContainerConstraint.isActive = hide
        self.bottomCollectionContainerConstraint.isActive = !hide
        self.mainCollection.collectionViewLayout.invalidateLayout()
        self.changeReorderButtonState(toActive: self.bottomCollectionContainerConstraint.isActive)
        
        UIView.animate(withDuration: AnimationDuration.medium, animations: { [weak self] in
            guard let `self` = self else { return }
            self.view.layoutIfNeeded()
            }, completion: { _ in
        })
    }
}

// MARK: UICollectionViewDataSource

extension MultipageReviewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageDocuments.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollection {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewMainCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewMainCollectionCell
            cell?.documentImage.image = imageDocuments[indexPath.row].previewImage
            return cell!
        } else {
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: MultipageReviewBottomCollectionCell.identifier,
                                     for: indexPath) as? MultipageReviewBottomCollectionCell
            if let image = imageDocuments[indexPath.row].previewImage {
                cell?.documentImage.contentMode = image.size.width > image.size.height ?
                    .scaleAspectFit :
                    .scaleAspectFill
                cell?.documentImage.image = image
            }
            cell?.pageIndicator.text = "\(indexPath.row + 1)"
            return cell!
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               moveItemAt sourceIndexPath: IndexPath,
                               to destinationIndexPath: IndexPath) {
        if collectionView == bottomCollection {
            var indexes = IndexPath.indexesBetween(sourceIndexPath, and: destinationIndexPath)
            indexes.append(sourceIndexPath)
            
            // On iOS < 11 the destinationIndexPath is not reloaded automatically.
            if ProcessInfo().operatingSystemVersion.majorVersion < 11 {
                indexes.append(destinationIndexPath)
            }
            
            let elementMoved = imageDocuments.remove(at: sourceIndexPath.row)
            imageDocuments.insert(elementMoved, at: destinationIndexPath.row)
            self.mainCollection.reloadData()
            
            // This is needed because this method is called before the dragging animation finishes.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                guard let `self` = self else { return }
                self.bottomCollection.reloadItems(at: indexes)
                self.selectItem(at: destinationIndexPath.row)
                self.didUpdateDocuments?(self.imageDocuments)
            })
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension MultipageReviewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == mainCollection ?
            collectionView.frame.size :
            MultipageReviewBottomCollectionCell.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomCollection {
            if imageDocuments.count > 1 {
                mainCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                bottomCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            changeTitle(withPage: indexPath.row + 1)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        return collectionView == mainCollection ? .zero : bottomCollectionInsets
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mainCollection {
            if let indexPath = visibleCell(in: mainCollection) {
                selectItem(at: indexPath.row)
            }
        }
    }
    
    func visibleImage(in collection: UICollectionView) -> (image: UIImage?, size: CGRect) {
        let visibleIndex = self.visibleCell(in: collection)
        guard let visibleCellIndex = visibleIndex,
            let cell = collectionView(collection,
                                      cellForItemAt: visibleCellIndex) as? MultipageReviewMainCollectionCell else {
                return (nil, .zero)
        }

        return (cell.documentImage.image, cell.frame)
    }
    
    func visibleCell(in collectionView: UICollectionView) -> IndexPath? {
        collectionView.layoutIfNeeded() // It is needed due to a bug in UIKit.
        return collectionView.indexPathsForVisibleItems.first
    }
}
