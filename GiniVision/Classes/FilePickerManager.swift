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
    
    fileprivate let MAX_FILE_SIZE = 10.0 // MB
    
    var didSelectPicture:((Data) -> ()) = { _ in }
    var didSelectPDF:((GiniPDFDocument) -> ()) = { _ in }
    
    // MARK: Picker presentation
    
    func showGalleryPicker(from:UIViewController) {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        from.present(imagePicker, animated: true, completion: nil)
    }
    
    func showDocumentPicker(from:UIViewController) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String, kUTTypeImage as String], in: .open)
        documentPicker.delegate = self
        from.present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK: File type check
    
    func maxFileSizeExceeded(forData data:Data) -> Bool {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        bcf.includesUnit = false
        
        if let fileSize = NumberFormatter().number(from: bcf.string(fromByteCount: Int64(data.count)))?.doubleValue {
            return fileSize > MAX_FILE_SIZE
        }
        
        return false
    }
    
    func isValidImage(imageData:Data) -> Bool {
        return imageData.isJPEG || imageData.isJPEG || imageData.isGIF || imageData.isTIFF
    }
    
    func isValidPDF(pdfDocument:GiniPDFDocument) -> Bool {
        if case 1...10 = pdfDocument.numberPages {
            return true
        }
        return false
    }
    
    // MARK: File processing
    
    fileprivate func processFile(fileData:Data){
        if !maxFileSizeExceeded(forData: fileData) {
            if fileData.isPDF && isValidPDF(pdfDocument: GiniPDFDocument(pdfData: fileData)) {
                let pdfDocument = GiniPDFDocument(pdfData: fileData)
                if isValidPDF(pdfDocument: pdfDocument) {
                    didSelectPDF(pdfDocument)
                } else {
                    // TODO Handle error
                }
            } else if fileData.isImage && isValidImage(imageData: fileData) {
                didSelectPicture(fileData)
            } else {
                // TODO Handle error
            }
        } else {
            // TODO Handle error
        }
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension FilePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(pickedImage, 1.0) {
            processFile(fileData: imageData)
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
            
            processFile(fileData: data)
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
                self.didSelectPDF(pdf)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { [unowned self] imageItems in
            if let images = imageItems as? [UIImage], let image = images.first, let imageData = UIImageJPEGRepresentation(image, 1.0) {
                self.didSelectPicture(imageData)
            }
        }
    }
}
