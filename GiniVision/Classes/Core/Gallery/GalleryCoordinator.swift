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

final class GalleryCoordinator: NSObject, Coordinator {
    
    weak var delegate: GalleryCoordinatorDelegate?
    let giniConfiguration: GiniConfiguration
    let galleryManager: GalleryManager = GalleryManager()
    var selectedImages: [String: UIImage] = [:]
    
    // View controllers
    var rootViewController: UIViewController {
        return containerNavigationController
    }
    
    lazy var containerNavigationController: ContainerNavigationController = {
        let container = ContainerNavigationController(rootViewController: self.galleryNavigator,
                                                      giniConfiguration: self.giniConfiguration)
        return container
    }()
    
    lazy var galleryNavigator: UINavigationController = {
        let navController = UINavigationController(rootViewController: self.albumsController)
        navController.applyStyle(withConfiguration: self.giniConfiguration)
        navController.delegate = self
        return navController
    }()
    
    lazy var albumsController: AlbumsPickerViewController = {
        let albumsPickerVC = AlbumsPickerViewController(galleryManager: self.galleryManager)
        albumsPickerVC.delegate = self
        albumsPickerVC.navigationItem.rightBarButtonItem = self.cancelButton
        return albumsPickerVC
    }()
    
    // Navigation bar buttons
    lazy var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel,
                                                             target: self,
                                                             action: #selector(closeGallery))
    
    lazy var openImagesButton: UIBarButtonItem = {
        let button = UIButton(type: UIButtonType.custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openImages), for: .touchUpInside)
        button.frame.size = CGSize(width: 70, height: 20)
        button.titleLabel?.textColor = .white
        let barButton = UIBarButtonItem(customView: button)
        return barButton
    }()
    
    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
    }
    
    func start() {
        if let firstAlbum = galleryManager.albums.first {
            let imagePicker = createImagePicker(with: firstAlbum)
            galleryManager.startCachingImages(for: firstAlbum, priority: .utility)
            galleryNavigator.pushViewController(imagePicker, animated: false)
        }
    }
    
    @objc func closeGallery() {
        selectedImages = [:]
        rootViewController.dismiss(animated: true, completion: nil)
        galleryNavigator.popToRootViewController(animated: false)
    }
    
    @objc func openImages() {
        let images: [UIImage] = selectedImages.map { $0.value }
        delegate?.gallery(self, didSelectImages: images)
        closeGallery()
    }
    
    fileprivate func createImagePicker(with album: Album) -> ImagePickerViewController {
        let imagePicker = ImagePickerViewController(album: album,
                                                    galleryManager: galleryManager,
                                                    giniConfiguration: giniConfiguration)
        imagePicker.delegate = self
        imagePicker.navigationItem.rightBarButtonItem = cancelButton
        return imagePicker
    }
    
    fileprivate func setUpDoneButton(with imagesCount: Int) {
        let innerButton = (self.openImagesButton.customView as? UIButton)
        let currentFont = innerButton?.titleLabel?.font
        
        UIView.performWithoutAnimation {
            let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: (currentFont?.pointSize)!)]
            let attributedString = NSMutableAttributedString(string: "Done ",
                                                             attributes: attributes)
            attributedString.append(NSAttributedString(string: "(\(imagesCount))"))
            innerButton?.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
}

// MARK: UINavigationControllerDelegate

extension GalleryCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let imagePicker = fromVC as? ImagePickerViewController {
            galleryManager.stopCachingImages(for: imagePicker.currentAlbum)
            selectedImages.removeAll()
        }
        return nil
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
    func imagePicker(_ viewController: ImagePickerViewController,
                     didSelectAssetAt index: IndexPath,
                     in album: Album) {
        if selectedImages.isEmpty {
            viewController.navigationItem.setRightBarButton(openImagesButton, animated: true)
        }
        galleryManager.fetchImage(from: album, at: index, imageQuality: .original) { image, localIdentifier in
            self.selectedImages[localIdentifier] = image
            self.setUpDoneButton(with: self.selectedImages.count)
        }

    }
    
    func imagePicker(_ viewController: ImagePickerViewController,
                     didDeselectAssetAt index: IndexPath,
                     in album: Album) {
        let deselectedAsset = album.assets[index.row]
        selectedImages.removeValue(forKey: deselectedAsset.localIdentifier)
        
        if selectedImages.isEmpty {
            viewController.navigationItem.setRightBarButton(cancelButton, animated: true)
        } else {
            setUpDoneButton(with: self.selectedImages.count)
        }
    }
}
