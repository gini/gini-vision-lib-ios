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
    
    override init() {
        super.init()
        DispatchQueue.global().async {
            self.galleryCoordinator.start()
        }
    }
    
    // MARK: Picker presentation
    
    func showGalleryPicker(from: UIViewController,
                           giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration,
                           errorHandler: @escaping (_ error: GiniVisionError) -> Void) {
        galleryCoordinator.checkGalleryAccessPermission(deniedHandler: errorHandler) {
            self.galleryCoordinator.delegate = self
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
                if let document = createDocument(fromData: data) {
                    documents.append(document)
                }
            }
        }
        
        didPickDocuments(documents)
    }
    
    fileprivate func createDocument(fromData data: Data) -> GiniVisionDocument? {
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
    
}

// MARK: GalleryCoordinatorDelegate

extension FilePickerManager: GalleryCoordinatorDelegate {
    func gallery(_ coordinator: GalleryCoordinator, didSelectImageDocuments imageDocuments: [GiniImageDocument]) {
        didPickDocuments(imageDocuments)
        
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
    }
    
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIDocumentPickerDelegate

extension FilePickerManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        processFilesPicked(fromUrls: urls)
        
        let documents: [GiniVisionDocument] = urls
            .flatMap(self.data)
            .flatMap(self.createDocument)
        
        didPickDocuments(documents)
        
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
                session.canLoadObjects(ofClass: GiniPDFDocument.self))
        case .pdf:
            return session.canLoadObjects(ofClass: GiniPDFDocument.self)
        case .none:
            return false
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: GiniPDFDocument.self) { [unowned self] pdfItems in
            if let pdfs = pdfItems as? [GiniPDFDocument], pdfs.isNotEmpty {
                self.didPickDocuments(pdfs)
            }
        }
        
        session.loadObjects(ofClass: GiniImageDocument.self) { [unowned self] imageItems in
            if let images = imageItems as? [GiniImageDocument], images.isNotEmpty {
                self.didPickDocuments(images)
            }
        }
    }
}
