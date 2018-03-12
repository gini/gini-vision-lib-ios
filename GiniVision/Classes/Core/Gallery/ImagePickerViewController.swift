//
//  ImagePickerViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import Photos

protocol ImagePickerViewControllerDelegate: class {
    func imagePicker(_ viewController: ImagePickerViewController, didSelectAsset asset: Asset)
    func imagePicker(_ viewController: ImagePickerViewController, didDeselectAsset  asset: Asset)
}

final class ImagePickerViewController: UIViewController {
    
    let currentAlbum: Album
    weak var delegate: ImagePickerViewControllerDelegate?
    fileprivate let galleryManager: GalleryManagerProtocol
    fileprivate let giniConfiguration: GiniConfiguration
    private var isInitialized: Bool = false
    private let multipleSelectionLimit: Int = 10
    
    // MARK: - Views
    
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
    
    // MARK: - Initializers
    
    init(album: Album,
         galleryManager: GalleryManagerProtocol,
         giniConfiguration: GiniConfiguration) {
        self.galleryManager = galleryManager
        self.giniConfiguration = giniConfiguration
        self.currentAlbum = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
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
    
    // MARK: - Others
 
    fileprivate func scrollToBottomOnStartup() {
        // This tweak is needed to fix an issue with the UICollectionView. UICollectionView doesn't
        // scroll to the bottom on `viewWillAppear`, which is right after `viewDidLayoutSubviews`.
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
        let asset = currentAlbum.assets[indexPath.row]
        cell?.fill(withAsset: asset,
                   multipleSelectionEnabled: giniConfiguration.multipageEnabled,
                   galleryManager: galleryManager)
        
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
        if let selectedIndexes = collectionView.indexPathsForSelectedItems, selectedIndexes.count > 10 {
            collectionView.deselectItem(at: indexPath, animated: false)
        } else {
            let asset = currentAlbum.assets[indexPath.row]
            delegate?.imagePicker(self, didSelectAsset: asset)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let asset = currentAlbum.assets[indexPath.row]
        delegate?.imagePicker(self, didDeselectAsset: asset)
    }
}
