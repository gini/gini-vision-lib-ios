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

internal final class FilePickerManager:NSObject {
    
    var didPickFile:((GiniVisionDocument) -> ()) = { _ in }
    fileprivate var acceptedDocumentTypes = GiniPDFDocument.acceptedPDFTypes + GiniImageDocument.acceptedImageTypes
    
    // MARK: Picker presentation
    
    func showGalleryPicker(from:UIViewController, errorHandler: @escaping (_ error: GiniVisionError) -> ()) {
        checkPhotoLibraryAccessPermission(deniedHandler: errorHandler) {
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            from.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func showDocumentPicker(from:UIViewController) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: acceptedDocumentTypes, in: .open)
        documentPicker.delegate = self
        from.present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK: FilePicked from gallery or document pickers
    
    fileprivate func filePicked(withData data: Data) {
        let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        documentBuilder.importMethod = .picker
        
        if let document = documentBuilder.build() {
            didPickFile(document)
        }
    }
    
    // MARK: Photo library permission
    
    fileprivate func checkPhotoLibraryAccessPermission(deniedHandler: @escaping (_ error: GiniVisionError) -> (), authorizedHandler: @escaping (() -> ())) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            authorizedHandler()
        case .denied, .restricted:
            deniedHandler(CameraError.notAuthorizedToAccessPhotoLibrary)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == PHAuthorizationStatus.authorized {
                    authorizedHandler()
                } else {
                    deniedHandler(CameraError.notAuthorizedToAccessPhotoLibrary)
                }
            }
        }
    }
    
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension FilePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(pickedImage, 1.0) {
            filePicked(withData: imageData)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIDocumentPickerDelegate

extension FilePickerManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        do {
            _ = url.startAccessingSecurityScopedResource()
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            
            filePicked(withData: data)
        } catch {
            // TODO Handle error
            url.stopAccessingSecurityScopedResource()
        }
        
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
        return (session.canLoadObjects(ofClass: GiniImageDocument.self) || session.canLoadObjects(ofClass: GiniPDFDocument.self)) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: GiniPDFDocument.self) { [unowned self] pdfItems in
            if let pdfs = pdfItems as? [GiniPDFDocument], let pdf = pdfs.first {
                self.didPickFile(pdf)
            }
        }
        
        session.loadObjects(ofClass: GiniImageDocument.self) { [unowned self] imageItems in
            if let images = imageItems as? [GiniImageDocument], let image = images.first {
                self.didPickFile(image)
            }
        }
    }
}
