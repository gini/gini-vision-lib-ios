//
//  GalleryPickerManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/28/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices
import Photos

internal final class FilePickerManager: NSObject {
    
    let galleryCoordinator = GalleryCoordinator(giniConfiguration: GiniConfiguration.sharedConfiguration)

    var didPickDocuments: (([GiniVisionDocument]) -> Void) = { _ in }
    fileprivate var acceptedDocumentTypes: [String] {
        switch GiniConfiguration.sharedConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return GiniPDFDocument.acceptedPDFTypes + GiniImageDocument.acceptedImageTypes
        case .pdf:
            return GiniPDFDocument.acceptedPDFTypes
        case .none:
            return []
        }
    }
    
    // MARK: Picker presentation
    
    func showGalleryPicker(from: UIViewController,
                           giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration,
                           errorHandler: @escaping (_ error: GiniVisionError) -> Void) {
        checkPhotoLibraryAccessPermission(deniedHandler: errorHandler) {
            setStatusBarStyle(to: .default)
            self.galleryCoordinator.start()
            from.present(self.galleryCoordinator.rootViewController, animated: true, completion: nil)
        }
    }
    
    func showDocumentPicker(from: UIViewController,
                            giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration,
                            device: UIDevice = UIDevice.current) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: acceptedDocumentTypes, in: .import)
        documentPicker.delegate = self
        
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = true
        }
        
        // This is needed since the UIDocumentPickerViewController on iPad is presented over the current view controller
        // without covering the previous screen. This causes that the `viewWillAppear` method is not being called
        // in the current view controller.
        if !device.isIpad {
            setStatusBarStyle(to: .default)
        }

        from.present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK: File data picked from gallery or document pickers
    
    fileprivate func processFilesPicked(fromUrls urls: [URL]) {
        var documents: [GiniVisionDocument] = []
        
        urls.forEach { url in
            if let data = data(fromUrl: url) {
                if let document = document(fromData: data) {
                    documents.append(document)
                }
            }
        }
        
        didPickDocuments(documents)
    }
    
    fileprivate func document(fromData data: Data) -> GiniVisionDocument? {
        let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        documentBuilder.importMethod = .picker
        
        return documentBuilder.build()
    }
    
    fileprivate func data(fromUrl url: URL) -> Data? {
        do {
            _ = url.startAccessingSecurityScopedResource()
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            
            return data
        } catch {
            url.stopAccessingSecurityScopedResource()
        }
        
        return nil
    }
    
    // MARK: Photo library permission
    
    fileprivate func checkPhotoLibraryAccessPermission(deniedHandler: @escaping (_ error: GiniVisionError) -> Void,
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

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension FilePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let imageData = UIImageJPEGRepresentation(pickedImage, 1.0),
            let document = document(fromData: imageData) {
            didPickDocuments([document])
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIDocumentPickerDelegate

extension FilePickerManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        processFilesPicked(fromUrls: urls)
        
        controller.dismiss(animated: false, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: UIDropInteractionDelegate

@available(iOS 11.0, *)
extension FilePickerManager: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        switch GiniConfiguration.sharedConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return (session.canLoadObjects(ofClass: GiniImageDocument.self) ||
                session.canLoadObjects(ofClass: GiniPDFDocument.self)) &&
                session.items.count == 1
        case .pdf:
            return session.canLoadObjects(ofClass: GiniPDFDocument.self) && session.items.count == 1
        case .none:
            return false
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: GiniPDFDocument.self) { [unowned self] pdfItems in
            if let pdfs = pdfItems as? [GiniPDFDocument], let pdf = pdfs.first {
                self.didPickDocuments([pdf])
            }
        }
        
        session.loadObjects(ofClass: GiniImageDocument.self) { [unowned self] imageItems in
            if let images = imageItems as? [GiniImageDocument], let image = images.first {
                self.didPickDocuments([image])
            }
        }
    }
}
