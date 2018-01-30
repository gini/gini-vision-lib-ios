//
//  MultipageReviewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

final class MultipageReviewController: UIViewController {
    
    var imageDocuments: [GiniImageDocument]
    var currentItemIndex: IndexPath = IndexPath(row: 0, section: 0)
    lazy var mainCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        
        collection.register(MultipageReviewCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewCollectionCell.identifier)
        return collection
    }()
    
    lazy var bottomCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        let sideInset: CGFloat = 375 / 2 - 40
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.clear
        collection.showsHorizontalScrollIndicator = false
        
        collection.register(MultipageReviewCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewCollectionCell.identifier)
        return collection
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change order", for: .normal)
        button.backgroundColor = Colors.Gini.blue
        button.setImage(UIImageNamedPreferred(named: "reviewRotateButton"), for: .normal)
        button.addTarget(self, action: #selector(enableChangeOrder), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)

        return button
    }()
    
    lazy var moveLeftButton = UIBarButtonItem.init(title: "Move left",
                                              style: .done,
                                              target: self,
                                              action: #selector(moveLeft))
    
    lazy var moveRightButton = UIBarButtonItem.init(title: "Move right",
                                                    style: .done,
                                                    target: self,
                                                    action: #selector(moveRight))
    
    lazy var doneButton = UIBarButtonItem.init(title: "Done",
                                               style: .done,
                                               target: self,
                                               action: #selector(done))
    
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
        view.addSubview(bottomCollection)
        view.addSubview(button)
        bottomCollection.alpha = 0
        
        Contraints.clip(view: mainCollection, toSuperView: self.view)
        
        Contraints.active(item: button, attr: .bottom, relatedBy: .equal, to: self.bottomLayoutGuide,
                          attr: .top)
        Contraints.active(item: button, attr: .centerX, relatedBy: .equal, to: self.view, attr: .centerX)
        Contraints.active(item: button, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing,
                          constant: -20)
        Contraints.active(item: button, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading, constant: 20)
        Contraints.active(item: button, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 60)
        
        Contraints.active(item: bottomCollection, attr: .bottom, relatedBy: .equal, to: self.button,
                          attr: .top, constant: -20)
        Contraints.active(item: bottomCollection, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        Contraints.active(item: bottomCollection, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
        Contraints.active(item: bottomCollection, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 120)
        
        self.navigationItem.setLeftBarButton(doneButton,
                                             animated: true)
    }
    
    func done() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func enableChangeOrder() {
        if bottomCollection.alpha == 0 {
            bottomCollection.alpha = 1
            self.checkOrderingButtonsStateFor(indexPath: currentItemIndex)
            self.navigationItem.setLeftBarButton(moveLeftButton,
                                                 animated: true)
            self.navigationItem.setRightBarButton(moveRightButton,
                                                       animated: true)
        } else {
            bottomCollection.alpha = 0
            self.navigationItem.setLeftBarButton(doneButton,
                                                 animated: true)
            self.navigationItem.setRightBarButton(nil,
                                                  animated: true)
        }
    }
    
    enum Position {
        case left, right
    }
    
    func moveRight() {
        moveItemTo(position: .right)
    }
    
    func moveLeft() {
        moveItemTo(position: .left)
    }
    
    func moveItemTo(position: Position) {
        if let indexPath = visibleCell(in: mainCollection) {
            let row = position == .left ? indexPath.row - 1 : indexPath.row + 1
            let newIndexPath = IndexPath(row: row, section: 0)
            imageDocuments.swapAt(indexPath.row, newIndexPath.row)
            mainCollection.reloadData()
            mainCollection.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: false)
            bottomCollection.moveItem(at: indexPath, to: newIndexPath)
            bottomCollection.scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
            changeTitle(withPage: newIndexPath.row + 1)
            checkOrderingButtonsStateFor(indexPath: newIndexPath)
        }
    }
    
    func checkOrderingButtonsStateFor(indexPath: IndexPath) {
        moveLeftButton.isEnabled = indexPath.row > 0
        moveRightButton.isEnabled = indexPath.row + 1 < imageDocuments.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitle(withPage: 1)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        bottomCollection.selectItem(at: currentItemIndex,
                                    animated: true,
                                    scrollPosition: .centeredHorizontally)
    }
    
    fileprivate func changeTitle(withPage page: Int) {
        title = "\(page) of \(imageDocuments.count)"
    }

}

extension MultipageReviewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageDocuments.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultipageReviewCollectionCell.identifier,
                                                      for: indexPath) as? MultipageReviewCollectionCell
        cell?.documentImage.image = imageDocuments[indexPath.row].previewImage
        cell?.shouldShowBorder = collectionView == bottomCollection
        cell?.documentImage.contentMode = collectionView == bottomCollection ? .scaleToFill : .scaleAspectFit
        return cell!
    }
    
}

extension MultipageReviewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollection {
            return collectionView.frame.size
        } else {
            return CGSize(width: 80, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomCollection {
            mainCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            bottomCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentItemIndex = indexPath
            checkOrderingButtonsStateFor(indexPath: indexPath)
            changeTitle(withPage: indexPath.row + 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == mainCollection {
            return .zero
        } else {
            let totalCellWidth = 40 * imageDocuments.count
            let totalSpacingWidth = 10 * (imageDocuments.count - 1)
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mainCollection {
            if let indexPath = visibleCell(in: mainCollection) {
                bottomCollection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                changeTitle(withPage: indexPath.row + 1)
                checkOrderingButtonsStateFor(indexPath: indexPath)
            }
        }
    }
    
    fileprivate func visibleCell(in collectionView: UICollectionView) -> IndexPath? {
        collectionView.layoutIfNeeded() // It is needed due to a bug in UIKit.
        return collectionView.indexPathsForVisibleItems.first
    }
}

final class MultipageReviewCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewCollectionCellIdentifier"
    var shouldShowBorder: Bool = false
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            if shouldShowBorder {
                self.layer.borderColor = isSelected ? Colors.Gini.blue.cgColor : UIColor.black.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(documentImage)
        self.layer.borderWidth = 2.0
        Contraints.clip(view: documentImage, toSuperView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
