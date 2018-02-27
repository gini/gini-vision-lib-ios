//
//  ImagePickerViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import Photos

final class ImagePickerViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 1
        collectionLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ImagePickerCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
        return collectionView
    }()
    
    let galleryManager: GalleryManagerProtocol
    let currentAlbum: Album
    
    init(album: Album,
         galleryManager: GalleryManagerProtocol,
         giniConfiguration: GiniConfiguration) {
        self.galleryManager = galleryManager
        self.currentAlbum = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
        
        Constraints.pin(view: collectionView, toSuperView: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.scrollToItem(at: IndexPath(row: currentAlbum.count - 1,
                                                  section: 0),
                                    at: .bottom,
                                    animated: false)
    }
}

// MARK: UICollectionViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier,
                                                      for: indexPath) as? ImagePickerCollectionViewCell
        galleryManager.fetchImage(from: currentAlbum, at: indexPath) { image in
            cell?.galleryImage.image = image
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentAlbum.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: UICollectionViewDelegate

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ImagePickerCollectionViewCell.size(itemsInARow: 4,
                                                      collectionViewLayout: collectionViewLayout)
    }
}

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImagePickerCollectionViewCell"
    
    lazy var galleryImage: UIImageView = {
        let galleryImage: UIImageView = UIImageView(frame: .zero)
        galleryImage.translatesAutoresizingMaskIntoConstraints = false
        galleryImage.contentMode = .scaleAspectFill
        galleryImage.clipsToBounds = true
        return galleryImage
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(galleryImage)
        
        Constraints.pin(view: galleryImage, toSuperView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func size(for screen: UIScreen = UIScreen.main,
                    itemsInARow: Int,
                    collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let width = screen.bounds.width / CGFloat(itemsInARow)
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: width, height: width)
        }
        
        let spacing = flowLayout.minimumInteritemSpacing * CGFloat(itemsInARow - 1)
        let widthWithoutSpacing = (screen.bounds.width - spacing) / CGFloat(itemsInARow)
        
        return CGSize(width: widthWithoutSpacing, height: widthWithoutSpacing)
    }
}
