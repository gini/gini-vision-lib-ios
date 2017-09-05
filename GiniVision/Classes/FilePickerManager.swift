//
//  GalleryPickerManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/28/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

internal final class FilePickerManager:NSObject {
        
    var didPickFile:((GiniVisionDocument) -> ()) = { _ in }
    
    // MARK: Picker presentation
    
    func showGalleryPicker(from:UIViewController) {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        from.present(imagePicker, animated: true, completion: nil)
    }
    
    func showDocumentPicker(from:UIViewController) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String, kUTTypeJPEG as String, kUTTypePNG as String, kUTTypeGIF as String, kUTTypeTIFF as String], in: .open)
        documentPicker.delegate = self
        from.present(documentPicker, animated: true, completion: nil)
    }
    
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension FilePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(pickedImage, 1.0) {
            let imageDocument = GiniImageDocument(data: imageData)
            didPickFile(imageDocument)
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
            
            if data.isPDF {
                let pdfDocument = GiniPDFDocument(data: data)
                didPickFile(pdfDocument)
            } else if data.isImage {
                let imageDocument = GiniImageDocument(data: data)
                didPickFile(imageDocument)
            }
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
        return (session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: GiniPDFDocument.self)) && session.items.count == 1
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
        
        session.loadObjects(ofClass: UIImage.self) { [unowned self] imageItems in
            if let images = imageItems as? [UIImage], let image = images.first, let imageData = UIImageJPEGRepresentation(image, 1.0) {
                let imageDocument = GiniImageDocument(data: imageData)
                self.didPickFile(imageDocument)
            }
        }
    }
}
