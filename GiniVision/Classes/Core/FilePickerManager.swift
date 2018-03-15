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
    
    let galleryCoordinator: GalleryCoordinator
    let giniConfiguration: GiniConfiguration
    var didPickDocuments: (([GiniVisionDocument]) -> Void) = { _ in }
    
    fileprivate var acceptedDocumentTypes: [String] {
        switch giniConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return GiniPDFDocument.acceptedPDFTypes + GiniImageDocument.acceptedImageTypes
        case .pdf:
            return GiniPDFDocument.acceptedPDFTypes
        case .none:
            return []
        }
    }
    
    // MARK: - Initializer
    
    init(giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.galleryCoordinator = GalleryCoordinator(giniConfiguration: giniConfiguration)
    }
    
    // MARK: - Start caching
    
    func startCaching() {
        DispatchQueue.global().async {
            self.galleryCoordinator.start()
        }
    }
    
    // MARK: Picker presentation
    
    func showGalleryPicker(from: UIViewController,
                           errorHandler: @escaping (_ error: GiniVisionError) -> Void) {
        galleryCoordinator.checkGalleryAccessPermission(deniedHandler: errorHandler) {
            self.galleryCoordinator.delegate = self
            from.present(self.galleryCoordinator.rootViewController, animated: true, completion: nil)
        }
    }
    
    func showDocumentPicker(from: UIViewController,
                            device: UIDevice = UIDevice.current) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: acceptedDocumentTypes, in: .import)
        documentPicker.delegate = self
        
        if #available(iOS 11.0, *) {
            documentPicker.allowsMultipleSelection = giniConfiguration.multipageEnabled
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
        coordinator.dismissGallery()
    }
    
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void) {
        coordinator.dismissGallery()
    }
}

// MARK: UIDocumentPickerDelegate

extension FilePickerManager: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
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
        let isItemsSelectionAllowed = session.items.count > 1 ? giniConfiguration.multipageEnabled : true
        switch giniConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return (session.canLoadObjects(ofClass: GiniImageDocument.self) ||
                session.canLoadObjects(ofClass: GiniPDFDocument.self)) && isItemsSelectionAllowed
        case .pdf:
            return session.canLoadObjects(ofClass: GiniPDFDocument.self) && isItemsSelectionAllowed
        case .none:
            return false
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let dispatchGroup = DispatchGroup()
        var documents: [GiniVisionDocument] = []

        loadDocuments(ofClass: GiniPDFDocument.self, from: session, in: dispatchGroup) { pdfItems in
            if let pdfs = pdfItems {
                documents.append(contentsOf: pdfs as [GiniVisionDocument])
            }
        }
        
        loadDocuments(ofClass: GiniImageDocument.self, from: session, in: dispatchGroup) { imageItems in
            if let images = imageItems {
                documents.append(contentsOf: images as [GiniVisionDocument])
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.didPickDocuments(documents)
        }
    }
    
    fileprivate func loadDocuments<T: NSItemProviderReading>(ofClass classs: T.Type,
                                                             from session: UIDropSession,
                                                             in group: DispatchGroup,
                                                             completion: @escaping (([T]?) -> Void)) {
        group.enter()
        session.loadObjects(ofClass: classs.self) { items in
            if let items = items as? [T], items.isNotEmpty {
                completion(items)
            } else {
                completion(nil)
            }
            group.leave()
        }
    }
}
