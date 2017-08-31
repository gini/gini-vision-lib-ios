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
    
    var didSelectPicture:((Data) -> ()) = { _ in }
    var didSelectPDF:((Data) -> ()) = { _ in }
    let imagePicker:UIImagePickerController
    let documentPicker:UIDocumentPickerViewController
    
    override init() {
        imagePicker = UIImagePickerController()
        documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String, kUTTypeImage as String], in: .open)
        super.init()
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        documentPicker.delegate = self
    }
    
    func showGalleryPicker(from:UIViewController) {
        from.present(imagePicker, animated: true, completion: nil)
    }
    
    func showDocumentPicker(from:UIViewController){
        from.present(documentPicker, animated: true, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension FilePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage, let imageData = UIImageJPEGRepresentation(pickedImage, 1.0) {
            didSelectPicture(imageData)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIDocumentPickerDelegate

extension FilePickerManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        _ = url.startAccessingSecurityScopedResource()
        do{
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            
            let uti = data.utiFromMimeType
            
            if UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeImage) {
                print("This is an image!")
                didSelectPicture(data)
            } else if UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypePDF) {
                print("This is a PDF!")
                didSelectPDF(data)
            }
        }catch{
            // TODO handle error
        }
        
    }
}

// MARK: UIDropInteractionDelegate

@available(iOS 11.0, *)
extension FilePickerManager: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return (session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: PDFDocument.self)) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: PDFDocument.self) { [unowned self] pdfItems in
            if let pdfs = pdfItems as? [PDFDocument], let pdf = pdfs.first, let pdfData = pdf.data {
                self.didSelectPDF(pdfData)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { [unowned self] imageItems in
            if let images = imageItems as? [UIImage], let image = images.first, let imageData = UIImageJPEGRepresentation(image, 1.0) {
                self.didSelectPicture(imageData)
            }
        }
    }
}


internal class PDFDocument:NSObject, NSItemProviderReading{
    let data:Data?
    
    required init(pdfData:Data, typeIdentifier:String) {
        data = pdfData
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(pdfData: data, typeIdentifier: typeIdentifier)
    }
}
