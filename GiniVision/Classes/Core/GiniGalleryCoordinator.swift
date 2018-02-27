//
//  GiniGalleryCoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation

final class GiniGalleryCoordinator {
    
    let giniConfiguration: GiniConfiguration
    let galleryManager: GalleryManager = GalleryManager()
    var rootViewController: UIViewController {
        return galleryNavigator
    }
    
    lazy var galleryNavigator: UINavigationController = {
        let navController = UINavigationController(rootViewController: self.albumsController)
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
    
}

extension GiniGalleryCoordinator: AlbumsPickerViewControllerDelegate {
    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        let imagePicker = ImagePickerViewController(album: album,
                                                        galleryManager: galleryManager,
                                                        giniConfiguration: giniConfiguration)
        galleryNavigator.pushViewController(imagePicker, animated: true)
    }
}
