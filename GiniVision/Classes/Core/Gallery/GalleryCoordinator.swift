//
//  GalleryCoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation
import Photos

protocol GalleryCoordinatorDelegate: class {
    func gallery(_ coordinator: GalleryCoordinator, didSelectImageDocuments imageDocuments: [GiniImageDocument])
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void)
}

final class GalleryCoordinator: NSObject, Coordinator {
    
    weak var delegate: GalleryCoordinatorDelegate?
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let galleryManager: GalleryManagerProtocol
    fileprivate(set) var selectedImageDocuments: [String: GiniImageDocument] = [:]
    
    // MARK: - View controllers

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
    
    // MARK: - Navigation bar buttons

    lazy var cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                             target: self,
                                                             action: #selector(cancelAction))
    
    lazy var openImagesButton: UIBarButtonItem = {
        let button = UIButton(type: UIButtonType.custom)
        button.addTarget(self, action: #selector(openImages), for: .touchUpInside)
        button.frame.size = CGSize(width: 50, height: 20)
        button.titleLabel?.textColor = .white
        
        let currentFont = button.titleLabel?.font
        let fontSize = currentFont?.pointSize ?? 18
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize)]
        let openLocalizedString = NSLocalizedString("ginivision.imagepicker.openbutton",
                                                    bundle: Bundle(for: GiniVision.self), 
                                                    comment: "Open button title")
        let attributedString = NSMutableAttributedString(string: openLocalizedString,
                                                         attributes: attributes)
        button.setAttributedTitle(attributedString, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 14/fontSize

        return UIBarButtonItem(customView: button)
    }()
    
    // MARK: - Initializer

    init(galleryManager: GalleryManagerProtocol = GalleryManager(), giniConfiguration: GiniConfiguration) {
        self.galleryManager = galleryManager
        self.giniConfiguration = giniConfiguration
    }
    
    // MARK: - Start
    
    func start() {
        if let firstAlbum = galleryManager.albums.first {
            let imagePicker = createImagePicker(with: firstAlbum)
            galleryManager.startCachingImages(for: firstAlbum)
            galleryNavigator.pushViewController(imagePicker, animated: false)
        }
    }
    
    // MARK: - Bar button actions
    
    @objc fileprivate func cancelAction() {
        selectedImageDocuments = [:]
        delegate?.gallery(self, didCancel: ())
    }
    
    @objc fileprivate func openImages() {
        let imageDocuments: [GiniImageDocument] = selectedImageDocuments.map { $0.value }
        delegate?.gallery(self, didSelectImageDocuments: imageDocuments)
        selectedImageDocuments.removeAll()
        galleryNavigator.popViewController(animated: true)
    }
    
    // MARK: - Image picker generation.
    
    fileprivate func createImagePicker(with album: Album) -> ImagePickerViewController {
        let imagePickerViewController = ImagePickerViewController(album: album,
                                                                  galleryManager: galleryManager,
                                                                  giniConfiguration: giniConfiguration)
        imagePickerViewController.delegate = self
        imagePickerViewController.navigationItem.rightBarButtonItem = cancelButton
        return imagePickerViewController
    }
    
    // MARK: Photo library permission
    
    func checkGalleryAccessPermission(deniedHandler: @escaping (_ error: GiniVisionError) -> Void,
                                      authorizedHandler: @escaping (() -> Void)) {
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            authorizedHandler()
        case .denied, .restricted:
            deniedHandler(FilePickerError.photoLibraryAccessDenied)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == PHAuthorizationStatus.authorized {
                        authorizedHandler()
                    } else {
                        deniedHandler(FilePickerError.photoLibraryAccessDenied)
                    }
                }
            }
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
            selectedImageDocuments.removeAll()
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
                     didSelectAsset asset: Asset) {
        if selectedImageDocuments.isEmpty {
            viewController.navigationItem.setRightBarButton(openImagesButton, animated: true)
        }
        
        galleryManager.fetchImageData(from: asset) { data in
            DispatchQueue.global().async {
                var data = data
                
                // Some pictures have a wrong bytes structure and are not processed as images.
                if !data.isImage {
                    if let image = UIImage(data: data),
                        let imageData = UIImageJPEGRepresentation(image, 1.0) {
                        data = imageData
                    }
                }
                let imageDocument = GiniImageDocument(data: data,
                                                      imageSource: .external,
                                                      imageImportMethod: .picker,
                                                      deviceOrientation: nil)
                self.selectedImageDocuments[asset.identifier] = imageDocument
            }
        }

    }
    
    func imagePicker(_ viewController: ImagePickerViewController,
                     didDeselectAsset asset: Asset) {
        if let index = selectedImageDocuments.index(forKey: asset.identifier) {
            selectedImageDocuments.remove(at: index)
        }
        
        if let selectedItems = viewController.collectionView.indexPathsForSelectedItems, selectedItems.isEmpty {
            viewController.navigationItem.setRightBarButton(cancelButton, animated: true)
        }
    }
}
