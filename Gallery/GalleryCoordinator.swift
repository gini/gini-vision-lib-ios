//
//  GalleryCoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation
import Photos

protocol GalleryCoordinatorDelegate: class {
    func gallery(_ coordinator: GalleryCoordinator, didSelectImages images: [UIImage])
}

final class GalleryCoordinator {
    
    weak var delegate: GalleryCoordinatorDelegate?
    let giniConfiguration: GiniConfiguration
    let galleryManager: GalleryManager = GalleryManager()
    var selectedAssetsIndexes: [IndexPath] = []
    var rootViewController: UIViewController {
        return galleryNavigator
    }
    
    lazy var galleryNavigator: UINavigationController = {
        let navController = UINavigationController(rootViewController: self.albumsController)
        navController.applyStyle(withConfiguration: self.giniConfiguration)
        return navController
    }()
    
    lazy var albumsController: AlbumsPickerViewController = {
        let albumsPickerVC = AlbumsPickerViewController(galleryManager: self.galleryManager)
        albumsPickerVC.delegate = self
        albumsPickerVC.navigationItem.rightBarButtonItem = self.cancelButton
        return albumsPickerVC
    }()
    
    lazy var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                                             target: self,
                                                             action: #selector(closeGallery))
    
    lazy var openImagesButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done,
                                                                 target: self,
                                                                 action: #selector(openImages))
    
    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
    }
    
    func start() {
        if let firstAlbum = galleryManager.albums.first {
            let imagePicker = createImagePicker(with: firstAlbum)
            galleryManager.startCachingImages(for: firstAlbum)
            galleryNavigator.pushViewController(imagePicker, animated: false)
        }
    }
    
    fileprivate func createImagePicker(with album: Album) -> ImagePickerViewController {
        let imagePicker = ImagePickerViewController(album: album,
                                                    galleryManager: galleryManager,
                                                    giniConfiguration: giniConfiguration)
        imagePicker.delegate = self
        imagePicker.navigationItem.rightBarButtonItem = cancelButton
        return imagePicker
    }
    
    @objc func closeGallery() {
        selectedAssetsIndexes = []
        rootViewController.dismiss(animated: true, completion: nil)
        galleryNavigator.popToRootViewController(animated: false)
    }
    
    @objc func openImages() {
        delegate?.gallery(self, didSelectImages: [])
        closeGallery()
    }
    
}

// MARK: - AlbumsPickerViewControllerDelegate

extension GalleryCoordinator: AlbumsPickerViewControllerDelegate {
    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        let imagePicker = createImagePicker(with: album)
        galleryNavigator.pushViewController(imagePicker, animated: true)
    }
}

// MARK: - ImagePickerViewControllerDelegate

extension GalleryCoordinator: ImagePickerViewControllerDelegate {
    func imagePicker(_ viewController: ImagePickerViewController, didSelectAssetAt index: IndexPath, in album: Album) {
        if selectedAssetsIndexes.isEmpty {
            viewController.navigationItem.setRightBarButton(openImagesButton, animated: true)
        }
        galleryManager.fetchImage(from: album, at: index, imageQuality: .original) { image, assetId in
            
        }
        selectedAssetsIndexes.append(index)
    }
}
