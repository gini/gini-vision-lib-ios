//
//  MultipageReviewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

final class MultipageReviewController: UIViewController {
    
    var imageDocuments: [GiniImageDocument]
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
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
        let sideInset: CGFloat = (bottomCollection.frame.width - MultipageReviewBottomCollectionCell.portraitSize.width) / 2
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
    
    lazy var bottomCollectionContainerConstraint: NSLayoutConstraint = {
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
    
    lazy var topCollectionContainerConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(item: self.bottomCollectionContainer,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: self.toolBar,
                                  attribute: .top,
                                  multiplier: 1.0,
                                  constant: 0)
    }()
    
    lazy var rotateButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "rotateImageIcon"),
                                  insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                  action: #selector(rotateSelectedImage))
    }()
    
    lazy var reorderButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "reorderPagesIcon"),
                                  insets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4),
                                  action: #selector(reorderAction))
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        return self.barButtonItem(withImage: UIImageNamedPreferred(named: "trashIcon"),
                                  insets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2),
                                  action: #selector(deleteSelectedImage))
    }()
    
    init(imageDocuments: [GiniImageDocument]) {
        self.imageDocuments = imageDocuments
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(imageDocuments:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(mainCollection)
        view.addSubview(bottomCollectionContainer)
        view.addSubview(toolBar)
        bottomCollectionContainer.addSubview(bottomCollection)
        bottomCollectionContainer.addSubview(bottomCollectionTopBorder)
        
        addConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectItem(at: 0)
        view.backgroundColor = mainCollection.backgroundColor
        if #available(iOS 9.0, *) {
            longPressGesture = UILongPressGestureRecognizer(target: self,
                                                            action: #selector(handleLongGesture))
            longPressGesture.delaysTouchesBegan = true
            bottomCollection.addGestureRecognizer(longPressGesture)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainCollection.backgroundColor = .clear
        view.backgroundColor = .clear
        bottomCollectionContainer.alpha = 0
        toolBar.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: AnimationDuration.fast, animations: {
            self.toolBar.alpha = 1
        }, completion: { _ in
            self.bottomCollectionContainer.alpha = 1
        })
    }
    
    func rotateSelectedImage() {
        if let currentIndexPath = visibleCell(in: self.mainCollection) {
            let mainCollectionCellImageView = (mainCollection
                .cellForItem(at: currentIndexPath) as? MultipageReviewMainCollectionCell)?
                .documentImage
            
            let bottomCollectionCell = (bottomCollection
                .cellForItem(at: currentIndexPath) as? MultipageReviewBottomCollectionCell)
            
            imageDocuments[currentIndexPath.row].rotatePreviewImage(degrees: 90)
            
            let imageRotated = imageDocuments[currentIndexPath.row].previewImage
            mainCollectionCellImageView?.image = imageRotated
            bottomCollectionCell?.documentImage.image = imageRotated
            bottomCollection.collectionViewLayout.invalidateLayout()
        }
    }
    
    func deleteSelectedImage() {
        if let currentIndexPath = visibleCell(in: self.mainCollection) {
            imageDocuments.remove(at: currentIndexPath.row)
            mainCollection.deleteItems(at: [currentIndexPath])
            bottomCollection.performBatchUpdates({
                self.bottomCollection.deleteItems(at: [currentIndexPath])
            }, completion: { _ in
                if self.imageDocuments.count > 0, currentIndexPath.row != self.imageDocuments.count {
                    var indexes = IndexPath.indexesBetween(currentIndexPath,
                                                           and: IndexPath(row: self.imageDocuments.count,
                                                                          section: 0))
                    indexes.append(currentIndexPath)
                    self.bottomCollection.reloadItems(at: indexes)
                }
            })
        }
    }
    
    func reorderAction() {
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
    
    fileprivate func selectItem(at position: Int) {
        let indexPath = IndexPath(row: position, section: 0)
        self.bottomCollection.selectItem(at: indexPath,
                                         animated: true,
                                         scrollPosition: .centeredHorizontally)
        self.collectionView(self.bottomCollection, didSelectItemAt: indexPath)
    }
    
    fileprivate func addConstraints() {
        // mainCollection
        Contraints.active(item: mainCollection, attr: .bottom, relatedBy: .equal, to: bottomCollectionContainer,
                          attr: .top)
        Contraints.active(item: mainCollection, attr: .top, relatedBy: .equal, to: topLayoutGuide,
                          attr: .bottom)
        Contraints.active(item: mainCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Contraints.active(item: mainCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // toolBar
        Contraints.active(item: toolBar, attr: .bottom, relatedBy: .equal, to: bottomLayoutGuide,
                          attr: .top)
        Contraints.active(item: toolBar, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Contraints.active(item: toolBar, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // bottomCollectionContainer
        Contraints.active(constraint: topCollectionContainerConstraint)
        Contraints.active(item: bottomCollectionContainer, attr: .trailing, relatedBy: .equal, to: view,
                          attr: .trailing)
        Contraints.active(item: bottomCollectionContainer, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        
        // bottomCollectionTopBorder
        Contraints.active(item: bottomCollectionTopBorder, attr: .top, relatedBy: .equal, to: bottomCollectionContainer,
                          attr: .top)
        Contraints.active(item: bottomCollectionTopBorder, attr: .leading, relatedBy: .equal,
                          to: bottomCollectionContainer, attr: .leading)
        Contraints.active(item: bottomCollectionTopBorder, attr: .trailing, relatedBy: .equal,
                          to: bottomCollectionContainer, attr: .trailing)
        Contraints.active(item: bottomCollectionTopBorder, attr: .height, relatedBy: .equal, to: nil,
                          attr: .notAnAttribute, constant: 0.5)
        
        // bottomCollection
        Contraints.active(item: bottomCollection, attr: .bottom, relatedBy: .equal, to: bottomCollectionContainer,
                          attr: .bottom)
        Contraints.active(item: bottomCollection, attr: .top, relatedBy: .equal, to: bottomCollectionContainer,
                          attr: .top)
        Contraints.active(item: bottomCollection, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
        Contraints.active(item: bottomCollection, attr: .leading, relatedBy: .equal, to: view, attr: .leading)
        Contraints.active(item: bottomCollection, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: MultipageReviewBottomCollectionCell.portraitSize.height +
                            bottomCollectionInsets.top +
                            bottomCollectionInsets.bottom)
    }
    
    @available(iOS 9.0, *)
    func handleLongGesture(gesture: UILongPressGestureRecognizer) {
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
    
}

// MARK: UICollectionViewDataSource

extension MultipageReviewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageDocuments.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
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
            cell?.documentImage.image = imageDocuments[indexPath.row].previewImage
            cell?.pageIndicator.text = "\(indexPath.row + 1)"
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        moveItemAt sourceIndexPath: IndexPath,
                        to destinationIndexPath: IndexPath) {
        if collectionView == bottomCollection {
            var indexes = IndexPath.indexesBetween(sourceIndexPath, and: destinationIndexPath)
            indexes.append(sourceIndexPath)
            let elementMoved = imageDocuments.remove(at: sourceIndexPath.row)
            imageDocuments.insert(elementMoved, at: destinationIndexPath.row)
            self.mainCollection.reloadData()
            
            // This is needed since this method is call before the moving animation finishes.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
                guard let `self` = self else { return }
                self.bottomCollection.reloadItems(at: indexes)
                self.selectItem(at: destinationIndexPath.row)
            })
        }
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension MultipageReviewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollection {
            return collectionView.frame.size
        } else {
            let imageOrientation = imageDocuments[indexPath.row].previewImage?.imageOrientation
            
            if imageOrientation == .up || imageOrientation == .down {
                return MultipageReviewBottomCollectionCell.portraitSize
            } else {
                return MultipageReviewBottomCollectionCell.landscapeSize
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomCollection {
            mainCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            bottomCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            changeTitle(withPage: indexPath.row + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == mainCollection {
            return .zero
        } else {
            return bottomCollectionInsets
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mainCollection {
            if let indexPath = visibleCell(in: mainCollection) {
                selectItem(at: indexPath.row)
            }
        }
    }
    
    fileprivate func visibleCell(in collectionView: UICollectionView) -> IndexPath? {
        collectionView.layoutIfNeeded() // It is needed due to a bug in UIKit.
        return collectionView.indexPathsForVisibleItems.first
    }
}
