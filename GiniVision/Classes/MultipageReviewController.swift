//
//  MultipageReviewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

final class MultipageReviewController: UIViewController {
    
    var imageDocuments: [GiniImageDocument]
    lazy var mainCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        
        collection.register(MultipageReviewCollectionCell.self,
                            forCellWithReuseIdentifier: MultipageReviewCollectionCell.identifier)
        return collection
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
        Contraints.clip(view: mainCollection, toSuperView: self.view)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitle(withPage: 1)
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        return cell!
    }
    
}

extension MultipageReviewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexPath = mainCollection.indexPathsForVisibleItems.first {
            changeTitle(withPage: indexPath.row + 1)
        }
        
    }
}

final class MultipageReviewCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewCollectionCellIdentifier"
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(documentImage)
        Contraints.clip(view: documentImage, toSuperView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
