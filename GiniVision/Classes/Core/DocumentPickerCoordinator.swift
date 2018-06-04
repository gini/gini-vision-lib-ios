//
//  GalleryPickerManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/28/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

/**
 The CameraViewControllerDelegate protocol defines methods that allow you to handle picked documents from both
 Gallery and Files Explorer.
 
 - note: Component API only.
 */
public protocol DocumentPickerCoordinatorDelegate: class {
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
                        didPick documents: [GiniVisionDocument])
}

/**
 Document picker types.
 ````
 case gallery
 case explorer
 ````
 */

@objc public enum DocumentPickerType: Int {
    /// Gallery picker
    case gallery
    
    /// File explorer picker
    case explorer
}

/**
 The DocumentPickerCoordinator class allows you to present both the gallery and file explorer or to setup drag and drop
 in a view. If you want to handle the picked elements, you have to assign a `DocumentPickerCoordinatorDelegate` to
 the `delegate` property.
 When using multipage and having imported/captured images, you have to update the `isPDFSelectionAllowed`
 property before showing the File explorer in order to filter out PDFs.
 
 - note: Component API only.
 */

public final class DocumentPickerCoordinator: NSObject {
    
    /**
     The object that acts as the delegate of the document picker coordinator.
     */
    public weak var delegate: DocumentPickerCoordinatorDelegate?
    
    /**
     Used to filter out PDFs when there are already imported images.
     */
    public var isPDFSelectionAllowed: Bool = true
    
    /**
     Once the user has selected one or several documents from a picker, this has to be dismissed.
     Files explorer dismissal is handled by the OS and drag and drop does not need to be dismissed.
     However, the Gallery picker should be dismissed once the images has been imported.
     
     It is also used to check if the `currentPickerViewController` is still present so
     an error dialog can be shown fro there
     */
    private(set) public var currentPickerDismissesAutomatically: Bool = false
    
    /**
     The current picker `UIViewController`. Used to show an error after validating picked documents.
     */
    private(set) public var currentPickerViewController: UIViewController?
    
    /**
     Indicates if the user granted access to the gallery before. Used to start caching images before showing the Gallery
     picker.
     */
    public var isGalleryPermissionGranted: Bool {
        return galleryCoordinator.isGalleryPermissionGranted
    }
    
    let galleryCoordinator: GalleryCoordinator
    let giniConfiguration: GiniConfiguration
    
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
    
    /**
     Designated initializer for the `DocumentPickerCoordinator`.
     
     - parameter giniConfiguration: `GiniConfiguration` use to configure the pickers.
     */
    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        self.galleryCoordinator = GalleryCoordinator(giniConfiguration: giniConfiguration)
    }
    
    /**
     Starts caching gallery images. Gallery permissions should have been granted before using it.
     */
    public func startCaching() {
        galleryCoordinator.start()
    }
    
    /**
     Set up the drag and drop feature in a view.
     
     - parameter view: View that will handle the drop interaction.
     - note: Only available in iOS >= 11
     */
    @available(iOS 11.0, *)
    public func setupDragAndDrop(in view: UIView) {
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }
    
    // MARK: Picker presentation
    
    /**
     Shows the Gallery picker from a given viewController
     
     - parameter viewController: View controller which presentes the gallery picker
     */
    public func showGalleryPicker(from viewController: UIViewController) {
        galleryCoordinator.checkGalleryAccessPermission(deniedHandler: { error in
            if let error = error as? FilePickerError, error == FilePickerError.photoLibraryAccessDenied {
                viewController.showErrorDialog(for: error, positiveAction: UIApplication.shared.openAppSettings)
            }
            }, authorizedHandler: {
                self.galleryCoordinator.delegate = self
                self.currentPickerDismissesAutomatically = false
                self.currentPickerViewController = self.galleryCoordinator.rootViewController
                viewController.present(self.galleryCoordinator.rootViewController, animated: true, completion: nil)
        })
    }
    
    /**
     Shows the File explorer picker from a given viewController
     
     - parameter viewController: View controller which presentes the gallery picker
     */
    public func showDocumentPicker(from viewController: UIViewController,
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
        
        self.currentPickerDismissesAutomatically = true
        self.currentPickerViewController = documentPicker
        
        viewController.present(documentPicker, animated: true, completion: nil)
    }
    
    /**
     Dimisses the `currentPickerViewController`
     
     - parameter completion: Completion block executed once the picker is dismissed
     */
    public func dismissCurrentPicker(completion: @escaping () -> Void) {
        if currentPickerDismissesAutomatically {
            completion()
        } else {
            self.galleryCoordinator.dismissGallery(completion: completion)
        }
        
        currentPickerViewController = nil
    }
}

// MARK: - Private methods

extension DocumentPickerCoordinator {
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
                 didSelectImageDocuments imageDocuments: [GiniImageDocument]) {
        delegate?.documentPicker(self,
                                 didPick: imageDocuments)
    }
    
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void) {
        coordinator.dismissGallery()
    }
}

// MARK: UIDocumentPickerDelegate

extension DocumentPickerCoordinator: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let documents: [GiniVisionDocument] = urls
            .compactMap(self.data)
            .compactMap(self.createDocument)
        
        delegate?.documentPicker(self, didPick: documents)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: UIDropInteractionDelegate

@available(iOS 11.0, *)
extension DocumentPickerCoordinator: UIDropInteractionDelegate {
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
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
    
    public func dropInteraction(_ interaction: UIDropInteraction,
                                sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
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
            self.currentPickerDismissesAutomatically = true
            self.delegate?.documentPicker(self, didPick: documents)
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
