//
//  GiniGalleryCoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation

final class GiniGalleryCoordinator {
    
    let giniConfiguration: GiniConfiguration
    let galleryManager: GiniGalleryImageManager = GiniGalleryImageManager()
    var rootViewController: UIViewController {
        return galleryNavigator
    }
    
    lazy var galleryNavigator: UINavigationController = {
        let navController = UINavigationController(rootViewController: self.albumsController)
        return navController
    }()
    
    lazy var albumsController: GiniAlbumsPickerViewController = {
        let albumsPickerVC = GiniAlbumsPickerViewController(galleryManager: self.galleryManager)
        albumsPickerVC.delegate = self
        return albumsPickerVC
    }()
    
    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
    }
    
}

extension GiniGalleryCoordinator: GiniAlbumsPickerViewControllerDelegate {
    func giniAlbumsPicker(_ viewController: GiniAlbumsPickerViewController, didSelectAlbum album: Album) {
        let imagePicker = GiniImagePickerViewController(album: album,
                                                        galleryManager: galleryManager,
                                                        giniConfiguration: giniConfiguration)
        galleryNavigator.pushViewController(imagePicker, animated: true)
    }
}
