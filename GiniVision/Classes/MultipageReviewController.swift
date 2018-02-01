//
//  MultipageReviewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

final class MultipageReviewController: UIViewController {
    
    var imageDocuments: [GiniImageDocument]
    fileprivate var currentItemIndex: IndexPath = IndexPath(row: 0, section: 0)
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
    
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: .zero)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.setItems([self.rotateButton,
                          flexibleSpace,
                          self.orderButton,
                          flexibleSpace,
                          self.deleteButton], animated: false)

        return toolBar
    }()
    
    lazy var rotateButton = UIBarButtonItem(image: UIImageNamedPreferred(named: "reviewRotateButton"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(rotateImage))
    
    lazy var orderButton = UIBarButtonItem(image: UIImageNamedPreferred(named: "reviewRotateButton"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(orderAction))
    
    lazy var deleteButton = UIBarButtonItem(image: UIImageNamedPreferred(named: "reviewRotateButton"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(deleteSelectedImage))
    
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
        view.addSubview(toolBar)
        
        addConstraints()
        navigationItem.setLeftBarButton(doneButton,
                                        animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitle(withPage: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func done() {
        self.dismiss(animated: true, completion: nil)
    }
    
    enum Position {
        case left, right
    }
    
    func rotateImage() {
        print("Rotate")
    }
    
    func deleteSelectedImage() {
        
    }
    
    func orderAction() {
        
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
        }
    }
    
    fileprivate func changeTitle(withPage page: Int) {
        title = "\(page) of \(imageDocuments.count)"
    }
    
    fileprivate func addConstraints() {
        Contraints.active(item: mainCollection, attr: .bottom, relatedBy: .equal, to: toolBar,
                          attr: .top)
        Contraints.active(item: mainCollection, attr: .top, relatedBy: .equal, to: self.topLayoutGuide,
                          attr: .bottom)
        Contraints.active(item: mainCollection, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        Contraints.active(item: mainCollection, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
        
        Contraints.active(item: toolBar, attr: .bottom, relatedBy: .equal, to: self.bottomLayoutGuide,
                          attr: .top)
        Contraints.active(item: toolBar, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        Contraints.active(item: toolBar, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
        
        Contraints.active(item: bottomCollection, attr: .bottom, relatedBy: .equal, to: toolBar,
                          attr: .top, constant: -20)
        Contraints.active(item: bottomCollection, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        Contraints.active(item: bottomCollection, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
        Contraints.active(item: bottomCollection, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                          constant: 120)
    }

}

// MARK: UICollectionViewDataSource

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

// MARK: UICollectionViewDelegateFlowLayout

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
            }
        }
    }
    
    fileprivate func visibleCell(in collectionView: UICollectionView) -> IndexPath? {
        collectionView.layoutIfNeeded() // It is needed due to a bug in UIKit.
        return collectionView.indexPathsForVisibleItems.first
    }
}
