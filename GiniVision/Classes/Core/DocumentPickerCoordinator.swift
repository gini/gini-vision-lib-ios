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

protocol DocumentPickerCoordinatorDelegate: class {
    /**
     Called when a user pick one or several files from both the gallery or files explorer.
     The completion might provide with errors than must be handled here before dismissing the
     pickers. It only applies for the `GalleryCoordinator` since on one side it is not possible
     to handle the dismissal of UIDocumentPickerViewController and the Drag&Drop is not done in a separate
     view.
     
     - parameter coordinator: `DocumentPickerCoordinator` where the documents were imported.
     - parameter documents: One or several documents imported.
     - parameter from: Picker used (either gallery, files explorer or drag&drop).
     - parameter completion: `DocumentPickerCompletion` block used to check if there is an issue with
     the captured documents. The completion block also has an inner block that is executed once the
     picker has been dismissed when there are no errors.
     */
    func documentPicker(_ coordinator: DocumentPickerCoordinator,
                        didPick documents: [GiniVisionDocument],
                        from picker: DocumentPickerType,
                        completion: DocumentPickerCompletion?)
}

public typealias DidDismissPickerCompletion = () -> Void
public typealias DocumentPickerCompletion = (Error?, DidDismissPickerCompletion?) -> Void

enum DocumentPickerType {
    case gallery, explorer, dragndrop
}

internal final class DocumentPickerCoordinator: NSObject {
    
    weak var delegate: DocumentPickerCoordinatorDelegate?
    let galleryCoordinator: GalleryCoordinator
    let giniConfiguration: GiniConfiguration
    
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
    
    func showGalleryPicker(from viewController: UIViewController) {
        galleryCoordinator.checkGalleryAccessPermission(deniedHandler: {[unowned self] error in
            if let error = error as? FilePickerError, error == FilePickerError.photoLibraryAccessDenied {
                self.showErrorDialog(for: error, from: viewController)
            }
            }, authorizedHandler: {
                self.galleryCoordinator.delegate = self
                viewController.present(self.galleryCoordinator.rootViewController, animated: true, completion: nil)
        })
    }
    
    func showDocumentPicker(from viewController: UIViewController,
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
        
        viewController.present(documentPicker, animated: true, completion: nil)
    }
    
    func showErrorDialog(for error: Error, from viewController: UIViewController) {
        let dialog: UIAlertController
        
        switch error {
        case let error as FilePickerError where error == .photoLibraryAccessDenied:
            dialog = errorDialog(withMessage: error.message,
                                 cancelActionTitle: "Abbrechen",
                                 confirmActionTitle: "Zugriff erteilen",
                                 confirmAction: UIApplication.shared.openAppSettings)
        case let error as FilePickerError where error == .filesPickedCountExceeded:

            dialog = errorDialog(withMessage: error.message,
                                 cancelActionTitle: "OK")
            
        default:
            return
        }
        
        viewController.present(dialog, animated: true, completion: nil)
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

extension DocumentPickerCoordinator: GalleryCoordinatorDelegate {
    func gallery(_ coordinator: GalleryCoordinator, didSelectImageDocuments imageDocuments: [GiniImageDocument]) {
        delegate?.documentPicker(self, didPick: imageDocuments, from: .gallery) { [weak self] error, didDismiss in
            guard let error = error else {
                coordinator.dismissGallery(completion: didDismiss)
                return
            }
            
            self?.showErrorDialog(for: error, from: coordinator.rootViewController)
        }
        
    }
    
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void) {
        coordinator.dismissGallery()
    }
}

// MARK: UIDocumentPickerDelegate

extension DocumentPickerCoordinator: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let documents: [GiniVisionDocument] = urls
            .flatMap(self.data)
            .flatMap(self.createDocument)
        
        delegate?.documentPicker(self, didPick: documents, from: .explorer, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: UIDropInteractionDelegate

@available(iOS 11.0, *)
extension DocumentPickerCoordinator: UIDropInteractionDelegate {
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
            self.delegate?.documentPicker(self, didPick: documents, from: .dragndrop, completion: nil)
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
