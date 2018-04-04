//
//  GiniScreenAPICoordinator+Camera.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Camera Screen

extension GiniScreenAPICoordinator: CameraViewControllerDelegate {
    func camera(_ viewController: CameraViewController, didCapture document: GiniVisionDocument) {
        let loadingView = viewController.addValidationLoadingView()
        
        validate([document]) { result in
            loadingView.removeFromSuperview()
            switch result {
            case .success:
                self.visionDocuments.append(document)
                if let imageDocument = document as? GiniImageDocument {
                    if self.giniConfiguration.multipageEnabled {
                        viewController.animateToControlsView(imageDocument: imageDocument)
                    } else {
                        self.showNextScreenAfterPicking(documents: [imageDocument])
                    }
                } else if let qrDocument = document as? GiniQRCodeDocument {
                    viewController.showPopup(forQRDetected: qrDocument) {
                        self.showNextScreenAfterPicking(documents: self.visionDocuments)
                    }
                }
            case .failure(let error):
                if let error = error as? FilePickerError, error == .maxFilesPickedCountExceeded {
                    viewController.showErrorDialog(for: error) {
                        let imageDocuments = self.visionDocuments.flatMap { $0 as? GiniImageDocument }
                        self.showMultipageReview(withImageDocuments: imageDocuments)
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
            documentPickerCoordinator.isPDFSelectionAllowed = visionDocuments.isEmpty
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
        if let imageDocuments = visionDocuments as? [GiniImageDocument] {
            showMultipageReview(withImageDocuments: imageDocuments)
        }
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
    
    private func didCaptureAndValidate(_ document: GiniVisionDocument) {
        if let didCapture = visionDelegate?.didCapture(document:) {
            didCapture(document)
        } else if let didCapture = visionDelegate?.didCapture(_:) {
            didCapture(document.data)
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
                                                title: "This is the title",
                                                subTitle: "This is the subtitle",
                                                image: UIImageNamedPreferred(named: "multipageIcon"),
                                                buttonTitle: "Let's scan!",
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
    
    func showNextScreenAfterPicking(documents: [GiniVisionDocument]) {
        if let firstDocument = documents.first, let documentsType = documents.type {
            switch documentsType {
            case .image:
                if let imageDocuments = self.visionDocuments as? [GiniImageDocument],
                    let lastDocument = imageDocuments.last {
                    if self.giniConfiguration.multipageEnabled {
                        if let imageDocuments = self.visionDocuments as? [GiniImageDocument],
                            lastDocument.isImported {
                            self.showMultipageReview(withImageDocuments: imageDocuments)
                        }
                    } else {
                        self.reviewViewController = self.createReviewScreen(withDocument: lastDocument)
                        self.screenAPINavigationController.pushViewController(self.reviewViewController!,
                                                                              animated: true)
                        self.didCaptureAndValidate(firstDocument)
                    }
                }
            case .qrcode, .pdf:
                self.analysisViewController = self.createAnalysisScreen(withDocument: firstDocument)
                self.screenAPINavigationController.pushViewController(self.analysisViewController!,
                                                                      animated: true)
                self.didCaptureAndValidate(firstDocument)
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
                    self.visionDocuments.append(contentsOf: validatedDocuments.map { $0.document })
                    self.showNextScreenAfterPicking(documents: validatedDocuments.map { $0.document })
                }
            case .failure(let error):
                var positiveAction: (() -> Void)?
                
                if let error = error as? FilePickerError {
                    switch error {
                    case .maxFilesPickedCountExceeded, .mixedDocumentsUnsupported:
                        let imageDocuments = self.visionDocuments.flatMap { $0 as? GiniImageDocument }
                        
                        if imageDocuments.isNotEmpty {
                            positiveAction = {
                                coordinator.dismissCurrentPicker {
                                    let imageDocuments = self.visionDocuments.flatMap { $0 as? GiniImageDocument }
                                    self.showMultipageReview(withImageDocuments: imageDocuments)
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
    
    fileprivate func validate(_ documents: [GiniVisionDocument],
                              completion: @escaping (Result<[ValidatedDocument]>) -> Void) {
        
        guard !(documents + visionDocuments).containsDifferentTypes else {
            completion(.failure(FilePickerError.mixedDocumentsUnsupported))
            return
        }
        
        guard (documents.count + visionDocuments.count) <= GiniPDFDocument.maxPagesCount else {
            completion(.failure(FilePickerError.maxFilesPickedCountExceeded))
            return
        }
        
        self.validate(importedDocuments: documents) { validatedDocuments in
            let elementsWithError = validatedDocuments.filter { $0.error != nil }
            if let firstElement = elementsWithError.first,
                let error = firstElement.1,
                (!self.giniConfiguration.multipageEnabled || firstElement.document.type != .image) {
                completion(.failure(error))
            } else {
                completion(.success(validatedDocuments))
            }
        }
    }
    
    fileprivate func validate(importedDocuments documents: [GiniVisionDocument],
                              completion: @escaping ([ValidatedDocument]) -> Void) {
        DispatchQueue.global().async {
            var validatedDocuments: [(GiniVisionDocument, Error?)] = []
            documents.forEach { document in
                var documentError: Error?
                do {
                    try document.validate(giniConfiguration: self.giniConfiguration)
                } catch let error {
                    documentError = error
                }
                validatedDocuments.append((document, documentError))
            }
            
            DispatchQueue.main.async {
                completion(validatedDocuments)
            }
        }
    }
    
}
