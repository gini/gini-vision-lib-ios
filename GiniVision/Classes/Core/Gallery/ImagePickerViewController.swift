//
//  ImagePickerViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import Photos

protocol ImagePickerViewControllerDelegate: class {
    func imagePicker(_ viewController: ImagePickerViewController, didSelectAssetAt index: IndexPath, in album: Album)
    func imagePicker(_ viewController: ImagePickerViewController, didDeselectAssetAt index: IndexPath, in album: Album)
}

final class ImagePickerViewController: UIViewController {
    
    let currentAlbum: Album
    weak var delegate: ImagePickerViewControllerDelegate?
    fileprivate let galleryManager: GalleryManagerProtocol
    private var isInitialized: Bool = false
    
    lazy var collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 1
        collectionLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.register(ImagePickerCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
        return collectionView
    }()
    
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
        
        title = currentAlbum.title
        view.backgroundColor = .white
        view.addSubview(collectionView)
        
        Constraints.pin(view: collectionView, toSuperView: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToBottomOnStartup()
    }
    
    fileprivate func scrollToBottomOnStartup() {
        // This tweak is needed to fix an issue with the UICollectionView. UICollectionView doesn't
        // scroll to the bottom on `viewWillAppear`, which is right after `viewDidLayoutSubviews`
        // Since this method can be called several times during the lifecycle, there should be
        // a one-time scrolling before the view appears for the first time.
        if !isInitialized {
            isInitialized = true
            collectionView.scrollToItem(at: IndexPath(row: currentAlbum.count - 1,
                                                      section: 0),
                                        at: .bottom,
                                        animated: false)
        }
    }
}

// MARK: UICollectionViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier,
                                                      for: indexPath) as? ImagePickerCollectionViewCell
        galleryManager.fetchImage(from: currentAlbum, at: indexPath.row, imageQuality: .thumbnail) { image, _ in
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.imagePicker(self, didSelectAssetAt: indexPath, in: currentAlbum)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        delegate?.imagePicker(self, didDeselectAssetAt: indexPath, in: currentAlbum)
    }
}
