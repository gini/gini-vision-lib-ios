//
//  GalleryCoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation
import Photos

protocol GalleryCoordinatorDelegate: class {
    func gallery(_ coordinator: GalleryCoordinator,
                 didSelectImageDocuments imageDocuments: [GiniImageDocument])
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void)
}

final class GalleryCoordinator: NSObject, Coordinator {
    
    weak var delegate: GalleryCoordinatorDelegate?
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let galleryManager: GalleryManagerProtocol
    fileprivate(set) var selectedImageDocuments: [String: GiniImageDocument] = [:]
    fileprivate var currentImagePickerViewController: ImagePickerViewController?
    
    var isGalleryPermissionGranted: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
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
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize)]
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
    
    // MARK: - Coordinator lifecycle
    
    func start() {
        DispatchQueue.global().async {
            if let firstAlbum = self.galleryManager.albums.first {                
                DispatchQueue.main.async {
                    self.galleryManager.startCachingImages(for: firstAlbum)
                    self.currentImagePickerViewController = self.createImagePicker(with: firstAlbum)
                    self.galleryNavigator.pushViewController(self.currentImagePickerViewController!, animated: false)
                }
            }
        }
    }
    
    func dismissGallery(completion: (() -> Void)? = nil) {
        rootViewController.dismiss(animated: true, completion: completion)
        resetToInitialState()
    }
    
    private func resetToInitialState() {
        self.selectedImageDocuments.removeAll()
        self.currentImagePickerViewController?.deselectAllCells()
        self.currentImagePickerViewController?.navigationItem.setRightBarButton(cancelButton, animated: true)
    }
    
    // MARK: - Bar button actions
    
    @objc fileprivate func cancelAction() {
        selectedImageDocuments = [:]
        delegate?.gallery(self, didCancel: ())
    }
    
    @objc fileprivate func openImages() {
        DispatchQueue.main.async {
            let imageDocuments: [GiniImageDocument] = self.selectedImageDocuments.map { $0.value }
            self.resetToInitialState()
            self.delegate?.gallery(self, didSelectImageDocuments: imageDocuments)
        }
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
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    if status == PHAuthorizationStatus.authorized {
                        self.galleryManager.reloadAlbums()
                        self.start()
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
            currentImagePickerViewController = nil
        }
        return nil
    }
}

// MARK: - AlbumsPickerViewControllerDelegate

extension GalleryCoordinator: AlbumsPickerViewControllerDelegate {
    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        currentImagePickerViewController = createImagePicker(with: album)
        galleryNavigator.pushViewController(currentImagePickerViewController!, animated: true)
    }
}

// MARK: - ImagePickerViewControllerDelegate

extension GalleryCoordinator: ImagePickerViewControllerDelegate {
    func imagePicker(_ viewController: ImagePickerViewController,
                     didSelectAsset asset: Asset,
                     at index: IndexPath) {
        if selectedImageDocuments.isEmpty {
            viewController.navigationItem.setRightBarButton(openImagesButton, animated: true)
        }
        
        galleryManager.fetchImageData(from: asset) { [weak self] data in
            guard let `self` = self else { return }
            if let data = data {
                viewController.selectCell(at: index)
                self.addSelected(asset, withData: data)
            } else {
                viewController.addToDownloadingItems(index: index)
                self.galleryManager.fetchRemoteImageData(from: asset) { [weak self] data in
                    guard let `self` = self else { return }
                    if let data = data {
                        viewController.removeFromDownloadingItems(index: index)
                        viewController.selectCell(at: index)
                        self.addSelected(asset, withData: data)
                    }
                }
            }
        }
        
    }
    
    func imagePicker(_ viewController: ImagePickerViewController,
                     didDeselectAsset asset: Asset,
                     at index: IndexPath) {
        if let documentIndex = selectedImageDocuments.index(forKey: asset.identifier) {
            viewController.deselectCell(at: index)
            selectedImageDocuments.remove(at: documentIndex)
        }
        
        if selectedImageDocuments.isEmpty {
            viewController.navigationItem.setRightBarButton(cancelButton, animated: true)
        }
    }
    
    private func addSelected(_ asset: Asset, withData data: Data) {
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
        
        if !self.giniConfiguration.multipageEnabled {
            openImages()
        }
    }
}
