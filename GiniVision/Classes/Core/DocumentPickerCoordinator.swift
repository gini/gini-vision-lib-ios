//
//  GalleryPickerManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/28/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

protocol DocumentPickerCoordinatorDelegate: class {
    /**
     Called when a user picks one or several files from either the gallery or the files explorer.
     The completion might provide errors that must be handled here before dismissing the
     pickers. It only applies to the `GalleryCoordinator` since on one side it is not possible
     to handle the dismissal of UIDocumentPickerViewController and on the other side
     the Drag&Drop is not done in a separate view.
     
     - parameter coordinator: `DocumentPickerCoordinator` where the documents were imported.
     - parameter documents: One or several documents imported.
     - parameter from: Picker used (either gallery, files explorer or drag&drop).
     - parameter validationHandler: `DocumentValidationHandler` block used to check if there is an issue with
     the captured documents. The handler has an inner completion block that is executed once the
     picker has been dismissed when there are no errors.
     */
    func documentPicker(_ coordinator: DocumentPickerCoordinator,
                        didPick documents: [GiniVisionDocument],
                        from picker: DocumentPickerType,
                        validationHandler: DocumentValidationHandler?)
}

public typealias DidDismissPickerCompletion = () -> Void
public typealias DocumentValidationHandler = (Error?, DidDismissPickerCompletion?) -> Void

enum DocumentPickerType {
    case gallery, explorer, dragndrop
}

internal final class DocumentPickerCoordinator: NSObject {
    
    weak var delegate: DocumentPickerCoordinatorDelegate?
    let galleryCoordinator: GalleryCoordinator
    let giniConfiguration: GiniConfiguration
    var isPDFSelectionAllowed: Bool = true
    
    var isGalleryPermissionGranted: Bool {
        return galleryCoordinator.isGalleryPermissionGranted
    }
    
    fileprivate var acceptedDocumentTypes: [String] {
        switch giniConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return isPDFSelectionAllowed ?
                GiniPDFDocument.acceptedPDFTypes + GiniImageDocument.acceptedImageTypes :
                GiniImageDocument.acceptedImageTypes
        case .pdf:
            return isPDFSelectionAllowed ? GiniPDFDocument.acceptedPDFTypes : []
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
        galleryCoordinator.start()
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
                                 cancelActionTitle: NSLocalizedStringPreferred("ginivision.camera.filepicker.errorPopup.cancelButton",
                                                                               comment: "cancel button title"),
                                 confirmActionTitle: NSLocalizedStringPreferred("ginivision.camera.filepicker.errorPopup.grantAccessButton",
                                                                                comment: "cancel button title"),
                                 confirmAction: UIApplication.shared.openAppSettings)
        case let error as FilePickerError where error == .maxFilesPickedCountExceeded:
            dialog = errorDialog(withMessage: error.message,
                                 cancelActionTitle: NSLocalizedStringPreferred("ginivision.camera.filepicker.errorPopup.confirmButton",
                                                                               comment: "cancel button title"))
            
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
    func gallery(_ coordinator: GalleryCoordinator,
                 didSelectImageDocuments imageDocuments: [GiniImageDocument],
                 completion: @escaping () -> Void) {
        delegate?.documentPicker(self, didPick: imageDocuments, from: .gallery) { [weak self] error, didDismiss in
            guard let error = error else {
                completion()
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
        
        delegate?.documentPicker(self, didPick: documents, from: .explorer, validationHandler: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: UIDropInteractionDelegate

@available(iOS 11.0, *)
extension DocumentPickerCoordinator: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        guard isPDFDropSelectionAllowed(forSession: session) else {
            return false
        }
        
        let isMultipleItemsSelectionAllowed = session.items.count > 1 ? giniConfiguration.multipageEnabled : true
        switch giniConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return (session.canLoadObjects(ofClass: GiniImageDocument.self) ||
                session.canLoadObjects(ofClass: GiniPDFDocument.self)) && isMultipleItemsSelectionAllowed
        case .pdf:
            return session.canLoadObjects(ofClass: GiniPDFDocument.self) && isMultipleItemsSelectionAllowed
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
            self.delegate?.documentPicker(self, didPick: documents, from: .dragndrop, validationHandler: nil)
        }
    }
    
    private func loadDocuments<T: NSItemProviderReading>(ofClass classs: T.Type,
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
    
    private func isPDFDropSelectionAllowed(forSession session: UIDropSession) -> Bool {
        if session.hasItemsConforming(toTypeIdentifiers: GiniPDFDocument.acceptedPDFTypes) {
            let pdfIdentifier = GiniPDFDocument.acceptedPDFTypes[0]
            let pdfItems = session.items.filter { $0.itemProvider.hasItemConformingToTypeIdentifier(pdfIdentifier) }
            
            if pdfItems.count > 1 || !isPDFSelectionAllowed {
                return false
            }
        }
        
        return true
    }
}
