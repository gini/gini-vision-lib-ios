//
//  GiniScreenAPICoordinator+Camera.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

/**
 The UploadDelegate protocol defines methods that allow you to notify the _Gini Vision Library_ when a document upload
 has finished (either successfully or with an error) 
 */
@objc public protocol UploadDelegate {
    func uploadDidFail(for document: GiniVisionDocument, with error: Error)
    func uploadDidComplete(for document: GiniVisionDocument)
}

extension GiniScreenAPICoordinator: CameraViewControllerDelegate {
    func camera(_ viewController: CameraViewController, didCapture document: GiniVisionDocument) {
        let loadingView = viewController.addValidationLoadingView()
        
        validate([document]) { result in
            loadingView.removeFromSuperview()
            switch result {
            case .success(let validatedDocuments):
                let validatedDocument = validatedDocuments[0]
                if let qrCodeDocument = document as? GiniQRCodeDocument {
                    viewController.showPopup(forQRDetected: qrCodeDocument) {
                        self.clearDocuments()
                        self.addToDocuments(new: [validatedDocument])
                        self.didCaptureAndValidate(document)
                        self.showNextScreenAfterPicking(documentRequests: self.documentRequests)
                    }
                } else if let imageDocument = document as? GiniImageDocument {
                    self.addToDocuments(new: [validatedDocument])
                    self.didCaptureAndValidate(document)
                    
                    // In case that there is more than one image already captured, an animation is shown instead of
                    // going to next screen
                    if self.documentRequests.count > 1 {
                        viewController.animateToControlsView(imageDocument: imageDocument)
                    } else {
                        self.showNextScreenAfterPicking(documentRequests: [validatedDocument])
                    }
                }
            case .failure(let error):
                if let error = error as? FilePickerError, error == .maxFilesPickedCountExceeded {
                    viewController.showErrorDialog(for: error) {
                        self.showMultipageReview()
                    }
                }
            }
        }
    }
    
    func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType) {
        switch documentPicker {
        case .gallery:
            documentPickerCoordinator.showGalleryPicker(from: viewController)
        case .explorer:
            documentPickerCoordinator.isPDFSelectionAllowed = documentRequests.isEmpty
            documentPickerCoordinator.showDocumentPicker(from: viewController)
        }
    }
    
    func cameraDidAppear(_ viewController: CameraViewController) {
        if shouldShowOnBoarding() {
            showOnboardingScreen()
        }
    }
    
    func cameraDidTapMultipageReviewButton(_ viewController: CameraViewController) {
        showMultipageReview()
    }
    
    func createCameraViewController() -> CameraViewController {
        let cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        cameraViewController.delegate = self
        cameraViewController.title = giniConfiguration.navigationBarCameraTitle
        cameraViewController.view.backgroundColor = giniConfiguration.backgroundColor
        
        cameraViewController.setupNavigationItem(usingResources: closeButtonResource,
                                                 selector: #selector(back),
                                                 position: .left,
                                                 target: self)
        
        cameraViewController.setupNavigationItem(usingResources: helpButtonResource,
                                                 selector: #selector(showHelpMenuScreen),
                                                 position: .right,
                                                 target: self)
        
        if giniConfiguration.fileImportSupportedTypes != .none {
            documentPickerCoordinator.delegate = self
            
            if documentPickerCoordinator.isGalleryPermissionGranted {
                documentPickerCoordinator.startCaching()
            }
            
            if #available(iOS 11.0, *) {
                documentPickerCoordinator.setupDragAndDrop(in: cameraViewController.view)
            }
        }
        
        return cameraViewController
    }
    
    fileprivate func didCaptureAndValidate(_ document: GiniVisionDocument) {
        visionDelegate?.didCapture(document: document, uploadDelegate: self)
    }
    
    private func shouldShowOnBoarding() -> Bool {
        if giniConfiguration.onboardingShowAtFirstLaunch &&
            !UserDefaults.standard.bool(forKey: "ginivision.defaults.onboardingShowed") {
            UserDefaults.standard.set(true, forKey: "ginivision.defaults.onboardingShowed")
            return true
        } else if giniConfiguration.onboardingShowAtLaunch {
            return true
        }
        
        return false
    }
    
    private func showOnboardingScreen() {
        cameraViewController?.hideCameraOverlay()
        cameraViewController?.hideCaptureButton()
        cameraViewController?.hideFileImportTip()
        
        let vc = OnboardingContainerViewController { [weak self] in
            guard let `self` = self else { return }
            self.cameraViewController?.showCameraOverlay()
            self.cameraViewController?.showCaptureButton()
            self.cameraViewController?.showFileImportTip()
        }
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.applyStyle(withConfiguration: giniConfiguration)
        navigationController.modalPresentationStyle = .overCurrentContext
        screenAPINavigationController.present(navigationController, animated: true, completion: nil)
    }
    
    func showNextScreenAfterPicking(documentRequests: [DocumentRequest]) {
        let visionDocuments = documentRequests.map { $0.document }
        if let firstDocument = visionDocuments.first, let documentsType = visionDocuments.type {
            switch documentsType {
            case .image:
                if let imageDocuments = visionDocuments as? [GiniImageDocument],
                    let lastDocument = imageDocuments.last {
                    if self.giniConfiguration.multipageEnabled {
                        showMultipageReview()
                    } else {
                        reviewViewController = createReviewScreen(withDocument: lastDocument)
                        screenAPINavigationController.pushViewController(reviewViewController!,
                                                                         animated: true)
                    }
                }
            case .qrcode, .pdf:
                showAnalysisScreen()
            }
        }
    }
    
}

// MARK: - DocumentPickerCoordinatorDelegate

extension GiniScreenAPICoordinator: DocumentPickerCoordinatorDelegate {
    
    func documentPicker(_ coordinator: DocumentPickerCoordinator,
                        didPick documents: [GiniVisionDocument]) {
        
        self.validate(documents) { result in
            switch result {
            case .success(let validatedDocuments):
                coordinator.dismissCurrentPicker {
                    self.addToDocuments(new: validatedDocuments)
                    validatedDocuments.forEach { validatedDocument in
                        if validatedDocument.error == nil {
                            self.didCaptureAndValidate(validatedDocument.document)
                        }
                    }
                    self.showNextScreenAfterPicking(documentRequests: validatedDocuments)
                }
            case .failure(let error):
                var positiveAction: (() -> Void)?
                
                if let error = error as? FilePickerError {
                    switch error {
                    case .maxFilesPickedCountExceeded, .mixedDocumentsUnsupported:
                        if self.documentRequests.isNotEmpty {
                            positiveAction = {
                                coordinator.dismissCurrentPicker {
                                    self.showMultipageReview()
                                }
                            }
                        }
                        
                    case .photoLibraryAccessDenied:
                        break
                    }
                }
                
                if coordinator.currentPickerDismissesAutomatically {
                    self.cameraViewController?.showErrorDialog(for: error,
                                                               positiveAction: positiveAction)
                } else {
                    coordinator.currentPickerViewController?.showErrorDialog(for: error,
                                                                             positiveAction: positiveAction)
                }
            }
            
        }
    }
    
    @available(iOS 11.0, *)
    fileprivate func addDropInteraction(forView view: UIView, with delegate: UIDropInteractionDelegate) {
        let dropInteraction = UIDropInteraction(delegate: delegate)
        view.addInteraction(dropInteraction)
    }
}

// MARK: - Validation

extension GiniScreenAPICoordinator {
    fileprivate func validate(_ documents: [GiniVisionDocument],
                              completion: @escaping (Result<[DocumentRequest]>) -> Void) {
        
        guard !(documents + documentRequests.map {$0.document}).containsDifferentTypes else {
            completion(.failure(FilePickerError.mixedDocumentsUnsupported))
            return
        }
        
        guard (documents.count + documentRequests.count) <= GiniVisionDocumentValidator.maxPagesCount else {
            completion(.failure(FilePickerError.maxFilesPickedCountExceeded))
            return
        }
        
        self.validate(importedDocuments: documents) { validatedDocuments in
            let elementsWithError = validatedDocuments.filter { $0.error != nil }
            if let firstElement = elementsWithError.first,
                let error = firstElement.error,
                (!self.giniConfiguration.multipageEnabled || firstElement.document.type != .image) {
                completion(.failure(error))
            } else {
                completion(.success(validatedDocuments))
            }
        }
    }
    
    private func validate(importedDocuments documents: [GiniVisionDocument],
                          completion: @escaping ([DocumentRequest]) -> Void) {
        DispatchQueue.global().async {
            var documentRequests: [DocumentRequest] = []
            documents.forEach { document in
                var documentError: Error?
                do {
                    try GiniVisionDocumentValidator.validate(document,
                                                             withConfig: self.giniConfiguration)
                } catch let error {
                    documentError = error
                }
                documentRequests.append(DocumentRequest(value: document, error: documentError))
            }
            
            DispatchQueue.main.async {
                completion(documentRequests)
            }
        }
    }
}

// MARK: - UploadDelegate

extension GiniScreenAPICoordinator: UploadDelegate {
    func uploadDidComplete(for document: GiniVisionDocument) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.update(document, withError: nil, isUploaded: true)
        }
    }
    
    func uploadDidFail(for document: GiniVisionDocument, with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.update(document, withError: error, isUploaded: false)

            if document.type != .image || !self.giniConfiguration.multipageEnabled {
                guard let error = error as? GiniVisionError else { return }
                self.displayError(withMessage: error.message, andAction: { [weak self] in
                    guard let `self` = self else { return }
                    self.didCaptureAndValidate(document)
                })
            }
        }
    }
}
