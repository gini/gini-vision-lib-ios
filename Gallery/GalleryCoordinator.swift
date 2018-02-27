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
        return albumsPickerVC
    }()
    
    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
    }
    
    func start() {
        if let firstAlbum = galleryManager.albums.first {
            let imagePicker = ImagePickerViewController(album: firstAlbum,
                                                        galleryManager: galleryManager,
                                                        giniConfiguration: giniConfiguration)
            galleryManager.startCachingImages(for: firstAlbum)
            galleryNavigator.pushViewController(imagePicker, animated: false)
        }
    }
    
}

// MARK: - AlbumsPickerViewControllerDelegate

extension GalleryCoordinator: AlbumsPickerViewControllerDelegate {
    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        let imagePicker = ImagePickerViewController(album: album,
                                                    galleryManager: galleryManager,
                                                    giniConfiguration: giniConfiguration)
        galleryNavigator.pushViewController(imagePicker, animated: true)
    }
}

// MARK: - ImagePickerViewControllerDelegate

extension GalleryCoordinator: ImagePickerViewControllerDelegate {
    func imagePicker(_ viewController: ImagePickerViewController, didSelectAssetAt index: IndexPath) {
        selectedAssetsIndexes.append(index)
    }
}
