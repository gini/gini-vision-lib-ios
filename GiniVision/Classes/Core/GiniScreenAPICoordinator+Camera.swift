//
//  GiniScreenAPICoordinator+Camera.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Camera Screen

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
                self.addToSessionDocuments(newDocuments: [validatedDocument])
                self.didCaptureAndValidate(document)
                
                if let imageDocument = document as? GiniImageDocument {
                    if self.giniConfiguration.multipageEnabled {
                        viewController.animateToControlsView(imageDocument: imageDocument)
                    } else {
                        self.showNextScreenAfterPicking(documents: [validatedDocument])
                    }
                } else if let qrDocument = document as? GiniQRCodeDocument {
                    viewController.showPopup(forQRDetected: qrDocument) {
                        self.showNextScreenAfterPicking(documents: self.sessionDocuments)
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
            documentPickerCoordinator.isPDFSelectionAllowed = sessionDocuments.isEmpty
            documentPickerCoordinator.showDocumentPicker(from: viewController)
        case .dragndrop: break
        }
    }
    
    func cameraDidAppear(_ viewController: CameraViewController) {
        if shouldShowOnBoarding() {
            showOnboardingScreen()
        } else if AlertDialogController.shouldShowNewMultipageFeature {
            showMultipageNewFeatureDialog()
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
                addDropInteraction(forView: cameraViewController.view, with: documentPickerCoordinator)
            }
        }
        
        return cameraViewController
    }
    
    fileprivate func didCaptureAndValidate(_ document: GiniVisionDocument) {
        if let didCaptureWithDelegate = visionDelegate?.didCapture(document:uploadDelegate:) {
            didCaptureWithDelegate(document, self)
        } else if let didCapture = visionDelegate?.didCapture(document:) {
            didCapture(document)
        } else {
            fatalError("GiniVisionDelegate.didCapture(document: GiniVisionDocument) should be implemented")
        }
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
    
    private func showMultipageNewFeatureDialog() {
        let alertDialog = AlertDialogController(giniConfiguration: giniConfiguration,
                                                title: "Multi-Page Rechnungsanalyse",
                                                message: "Jetzt ist es möglich, eine Rechnung mit mehreren Seiten zu analysieren",
                                                image: UIImageNamedPreferred(named: "multipageIcon"),
                                                buttonTitle: "Zur Kamera",
                                                buttonImage: UIImage(named: "cameraIcon",
                                                                     in: Bundle(for: GiniVision.self),
                                                                     compatibleWith: nil))
        alertDialog.continueAction = {
            alertDialog.dismiss(animated: true, completion: nil)
            AlertDialogController.shouldShowNewMultipageFeature = false
        }
        alertDialog.cancelAction = alertDialog.continueAction
        screenAPINavigationController.present(alertDialog,
                                              animated: true,
                                              completion: nil)
    }
    
    func showNextScreenAfterPicking(documents: [ValidatedDocument]) {
        let visionDocuments = documents.map { $0.value }
        if let firstDocument = visionDocuments.first, let documentsType = visionDocuments.type {
            switch documentsType {
            case .image:
                if let imageDocuments = visionDocuments as? [GiniImageDocument],
                    let lastDocument = imageDocuments.last {
                    if self.giniConfiguration.multipageEnabled {
                        if lastDocument.isImported {
                            showMultipageReview()
                        }
                    } else {
                        reviewViewController = createReviewScreen(withDocument: lastDocument)
                        screenAPINavigationController.pushViewController(reviewViewController!,
                                                                         animated: true)
                    }
                }
            case .qrcode, .pdf:
                analysisViewController = createAnalysisScreen(withDocument: firstDocument)
                screenAPINavigationController.pushViewController(analysisViewController!,
                                                                 animated: true)
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
                    self.addToSessionDocuments(newDocuments: validatedDocuments)
                    validatedDocuments.forEach { validatedDocument in
                        if validatedDocument.error == nil {
                            self.didCaptureAndValidate(validatedDocument.value)
                        }
                    }
                    self.showNextScreenAfterPicking(documents: validatedDocuments)
                }
            case .failure(let error):
                var positiveAction: (() -> Void)?
                
                if let error = error as? FilePickerError {
                    switch error {
                    case .maxFilesPickedCountExceeded, .mixedDocumentsUnsupported:
                        if self.sessionDocuments.isNotEmpty {
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
                    coordinator.rootViewController?.showErrorDialog(for: error,
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
                              completion: @escaping (Result<[ValidatedDocument]>) -> Void) {
        
        guard !(documents + sessionDocuments.map {$0.value}).containsDifferentTypes else {
            completion(.failure(FilePickerError.mixedDocumentsUnsupported))
            return
        }
        
        guard (documents.count + sessionDocuments.count) <= GiniVisionDocumentValidator.maxPagesCount else {
            completion(.failure(FilePickerError.maxFilesPickedCountExceeded))
            return
        }
        
        self.validate(importedDocuments: documents) { validatedDocuments in
            let elementsWithError = validatedDocuments.filter { $0.error != nil }
            if let firstElement = elementsWithError.first,
                let error = firstElement.error,
                (!self.giniConfiguration.multipageEnabled || firstElement.value.type != .image) {
                completion(.failure(error))
            } else {
                completion(.success(validatedDocuments))
            }
        }
    }
    
    private func validate(importedDocuments documents: [GiniVisionDocument],
                          completion: @escaping ([ValidatedDocument]) -> Void) {
        DispatchQueue.global().async {
            var validatedDocuments: [ValidatedDocument] = []
            documents.forEach { document in
                var documentError: Error?
                do {
                    try GiniVisionDocumentValidator.validate(document,
                                                             withConfig: self.giniConfiguration)
                } catch let error {
                    documentError = error
                }
                validatedDocuments.append(ValidatedDocument(value: document, error: documentError))
            }
            
            DispatchQueue.main.async {
                completion(validatedDocuments)
            }
        }
    }
}

// MARK: - UploadDelegate

extension GiniScreenAPICoordinator: UploadDelegate {
    func uploadDidComplete(for document: GiniVisionDocument) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.updateUploadStatusInSessionDocuments(for: document, to: true)
            self.refreshMultipageReview(with: self.sessionDocuments)
        }
    }
    
    func uploadDidFail(for document: GiniVisionDocument, with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.updateErrorInSessionDocuments(for: document, to: error)
            self.refreshMultipageReview(with: self.sessionDocuments)
        }
    }
}
