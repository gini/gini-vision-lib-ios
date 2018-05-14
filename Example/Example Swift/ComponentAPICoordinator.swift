//
//  ComponentAPICoordinator.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 9/25/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import Foundation
import GiniVision
import Gini_iOS_SDK

protocol ComponentAPICoordinatorDelegate: class {
    func componentAPI(coordinator: ComponentAPICoordinator, didFinish:())
}

final class ComponentAPICoordinator: NSObject, Coordinator {
    
    weak var delegate: ComponentAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return self.componentAPITabBarController
    }
    
    fileprivate var documentService: DocumentServiceProtocol?
    fileprivate var documentRequests: [DocumentRequest]
    
    fileprivate let giniColor = UIColor(red: 0, green: (157/255), blue: (220/255), alpha: 1)
    fileprivate let giniConfiguration: GiniConfiguration
    
    fileprivate lazy var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    fileprivate lazy var componentAPIOnboardingViewController: ComponentAPIOnboardingViewController =
        (self.storyboard.instantiateViewController(withIdentifier: "componentAPIOnboardingViewController")
            as? ComponentAPIOnboardingViewController)!
    fileprivate lazy var navigationController: UINavigationController = {
        let navBarViewController = UINavigationController()
        navBarViewController.navigationBar.barTintColor = self.giniColor
        navBarViewController.navigationBar.tintColor = .white
        navBarViewController.view.backgroundColor = .black

        return navBarViewController
    }()
    
    fileprivate lazy var componentAPITabBarController: UITabBarController = {
        let tabBarViewController = UITabBarController()
        tabBarViewController.tabBar.barTintColor = self.giniColor
        tabBarViewController.tabBar.tintColor = .white
        tabBarViewController.view.backgroundColor = .black
        
        if #available(iOS 10.0, *) {
            tabBarViewController.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
        }
        
        return tabBarViewController
    }()
    
    fileprivate(set) lazy var multipageReviewScreen: MultipageReviewViewController = {
        let multipageReviewScreen = MultipageReviewViewController(documentRequests: documentRequests,
                                                                  giniConfiguration: giniConfiguration)
        multipageReviewScreen.delegate = self
        addCloseButtonIfNeeded(onViewController: multipageReviewScreen)
        let weiterBarButton = UIBarButtonItem(title: NSLocalizedString("next", comment: "weiter button text"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(showAnalysisScreen))
        weiterBarButton.isEnabled = false
        multipageReviewScreen.navigationItem.rightBarButtonItem = weiterBarButton
        return multipageReviewScreen
    }()
    
    fileprivate(set) var analysisScreen: AnalysisViewController?
    fileprivate(set) var cameraScreen: CameraViewController?
    fileprivate(set) var resultsScreen: ResultTableViewController?
    fileprivate(set) var reviewScreen: ReviewViewController?
    fileprivate(set) lazy var documentPickerCoordinator =
        DocumentPickerCoordinator(giniConfiguration: giniConfiguration)

    init(documentRequests: [DocumentRequest],
         configuration: GiniConfiguration,
         client: GiniClient) {
        self.documentRequests = documentRequests
        self.giniConfiguration = configuration
        super.init()
        
        setupDocumentService(client: client, giniConfiguration: configuration)
        GiniVision.setConfiguration(configuration)
    }
    
    func setupDocumentService(client: GiniClient,
                              giniConfiguration: GiniConfiguration) {
        let builder = GINISDKBuilder.anonymousUser(withClientID: client.clientId,
                                                   clientSecret: client.clientSecret,
                                                   userEmailDomain: client.clientEmailDomain)
        
        if let sdk = builder?.build() {
            if giniConfiguration.multipageEnabled {
                documentService = MultipageDocumentsService(sdk: sdk)
            } else {
                documentService = SinglePageDocumentsService(sdk: sdk)
            }
        }
    }
    
    func start() {
        self.setupTabBar()
        self.navigationController.delegate = self
        
        if documentRequests.isEmpty {
            showCameraScreen()
        } else {
            if documentRequests.type == .image {
                if giniConfiguration.multipageEnabled {
                    showMultipageReviewScreen()
                } else {
                    showReviewScreen()
                }
            } else {
                showAnalysisScreen()
            }
        }
    }
}

// MARK: Screens presentation

extension ComponentAPICoordinator {
    fileprivate func showCameraScreen() {
        cameraScreen = CameraViewController(giniConfiguration: giniConfiguration)
        cameraScreen?.delegate = self
        cameraScreen?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("close",
                                                                                                  comment: "close button text"),
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(closeComponentAPI))
        
        if giniConfiguration.fileImportSupportedTypes != .none {
            documentPickerCoordinator.delegate = self
            
            if giniConfiguration.fileImportSupportedTypes == .pdf_and_images,
                documentPickerCoordinator.isGalleryPermissionGranted {
                documentPickerCoordinator.startCaching()
            }
            
            if #available(iOS 11.0, *) {
                documentPickerCoordinator.setupDragAndDrop(in: cameraScreen!.view)
            }
        }
        navigationController.pushViewController(cameraScreen!, animated: true)
    }
    
    fileprivate func showMultipageReviewScreen() {
        navigationController.pushViewController(multipageReviewScreen, animated: true)
    }
    
    fileprivate func showReviewScreen() {
        guard let document = documentRequests.first?.document else { return }
        reviewScreen = ReviewViewController(document: document, giniConfiguration: giniConfiguration)
        reviewScreen?.delegate = self
        addCloseButtonIfNeeded(onViewController: reviewScreen!)
        reviewScreen?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("next",
                                                                                                   comment: "close button text"),
                                                                          style: .plain,
                                                                          target: self,
                                                                          action: #selector(showAnalysisScreen))
        
        navigationController.pushViewController(reviewScreen!, animated: true)
    }
    
    @objc fileprivate func showAnalysisScreen() {
        guard let document = documentRequests.first?.document else { return }
        
        startAnalysis()
        analysisScreen = AnalysisViewController(document: document)
        addCloseButtonIfNeeded(onViewController: analysisScreen!)
        
        navigationController.pushViewController(analysisScreen!, animated: true)
    }
    
    fileprivate func showResultsTableScreen(withExtractions extractions: [String: GINIExtraction]) {
        resultsScreen = storyboard.instantiateViewController(withIdentifier: "resultScreen")
            as? ResultTableViewController
        resultsScreen?.result = extractions
        
        if navigationController.viewControllers.first is AnalysisViewController {
            resultsScreen!.navigationItem
                .rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("close",
                                                                               comment: "close button text"),
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(closeComponentAPIFromResults))
        }
        
        push(viewController: resultsScreen!, removingViewControllerOfType: AnalysisViewController.self)
        analysisScreen = nil
    }
    
    fileprivate func showNoResultsScreen() {
        let vc: UIViewController
        if documentRequests.type == .image {
            let imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController()
            imageAnalysisNoResultsViewController.didTapBottomButton = { [unowned self] in
                self.didTapRetry()
            }
            vc = imageAnalysisNoResultsViewController
        } else {
            let genericNoResults = storyboard
                .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController
            genericNoResults!.delegate = self
            vc = genericNoResults!
        }
        
        push(viewController: vc, removingViewControllerOfType: AnalysisViewController.self)
        analysisScreen = nil

    }
    
    fileprivate func showNextScreenAfterPicking() {
        if let documentsType = documentRequests.type {
            switch documentsType {
            case .image:
                if giniConfiguration.multipageEnabled {
                    refreshMultipageReview(with: self.documentRequests)
                    showMultipageReviewScreen()
                } else {
                    showReviewScreen()
                }
            case .qrcode, .pdf:
                showAnalysisScreen()
            }
        }
    }
    
    @objc fileprivate func closeComponentAPI() {
        documentService?.cancelAnalysis()
        delegate?.componentAPI(coordinator: self, didFinish: ())
    }
    
    @objc fileprivate func closeComponentAPIFromResults() {
        if let results = resultsScreen?.result {
            documentService?.sendFeedback(with: results)
        }
        closeComponentAPI()
    }
    
    fileprivate func push<T>(viewController: UIViewController, removingViewControllerOfType: T.Type) {
        var navigationStack = navigationController.viewControllers
        
        if let deleteViewController = (navigationStack.compactMap { $0 as? T }.first) as? UIViewController,
            let index = navigationStack.index(of: deleteViewController) {
            navigationStack.remove(at: index)
        }
        navigationStack.append(viewController)
        navigationController.setViewControllers(navigationStack, animated: true)
    }
    
    fileprivate func refreshMultipageReview(with documentRequests: [DocumentRequest]) {
        multipageReviewScreen.navigationItem
            .rightBarButtonItem?
            .isEnabled = documentRequests
                .reduce(true, { result, documentRequest in
                    result && documentRequest.isUploaded
                })
        multipageReviewScreen.updateCollections(with: documentRequests)
    }
}

// MARK: - Networking

extension ComponentAPICoordinator {
    fileprivate func upload(documentRequests: [DocumentRequest]) {
        documentRequests.forEach { documentRequest in
            if documentRequest.error == nil {
                self.upload(documentRequest: documentRequest)
            }
        }
    }
    
    private func upload(documentRequest: DocumentRequest) {
        self.documentService?.upload(documentRequest.document) { result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let index = self.documentRequests
                    .index(of: documentRequest.document) else { return }
                switch result {
                case .success:
                    self.documentRequests[index].isUploaded = true
                case .failure(let error):
                    self.documentRequests[index].error = error
                }
                
                // When multipage mode is used and documents are image, you have to refresh the multipage review screen
                if self.giniConfiguration.multipageEnabled, self.documentRequests.type == .image {
                    self.refreshMultipageReview(with: self.documentRequests)
                }
            }
        }
    }
    
    fileprivate func startAnalysis() {
        documentService?.startAnalysis(completion: { result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                switch result {
                case .success(let extractions):
                    self.handleAnalysis(with: extractions)
                case .failure:
                    let visionError = CustomAnalysisError.analysisFailed
                    self.analysisScreen?.showErrorDialog(for: visionError, positiveAction: {
                        self.startAnalysis()
                    })
                }
            }
        })
    }
    
    fileprivate func delete(document: GiniVisionDocument) {
        documentService?.delete(document)
    }
}

// MARK: - Other

extension ComponentAPICoordinator {
    
    fileprivate func setupTabBar() {
        let newDocumentTabTitle = NSLocalizedString("newDocument",
                                                    comment: "new document tab title")
        let helpTabTitle = NSLocalizedString("help",
                                             comment: "new document tab title")
        let navTabBarItem = UITabBarItem(title: newDocumentTabTitle, image: UIImage(named: "tabBarIconNewDocument"), tag: 0)
        let helpTabBarItem = UITabBarItem(title: helpTabTitle, image: UIImage(named: "tabBarIconHelp"), tag: 1)
        
        self.navigationController.tabBarItem = navTabBarItem
        self.componentAPIOnboardingViewController.tabBarItem = helpTabBarItem
        
        self.componentAPITabBarController.setViewControllers([navigationController,
                                                              componentAPIOnboardingViewController],
                                                             animated: true)
    }
    
    fileprivate func addCloseButtonIfNeeded(onViewController viewController: UIViewController) {
        if navigationController.viewControllers.isEmpty {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("close",
                                                                                                       comment: "close button text"),
                                                                              style: .plain,
                                                                              target: self,
                                                                              action: #selector(closeComponentAPI))
        }
    }
    
    func didTapRetry() {
        if (navigationController.viewControllers.compactMap { $0 as? CameraViewController}).first == nil {
            closeComponentAPI()
            return
        }

        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: UINavigationControllerDelegate

extension ComponentAPICoordinator: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC is ReviewViewController && operation == .pop {
            reviewScreen = nil
            if let document = documentRequests.first?.document {
                documentService?.delete(document)
            }
            documentRequests.removeAll()
        }
        
        if fromVC is AnalysisViewController && operation == .pop {
            // Going directly from the analysis to the camera means that
            // the document is not an image and should be removed
            if toVC is CameraViewController {
                documentRequests.removeAll()
            }
            
            analysisScreen = nil
            documentService?.cancelAnalysis()
        }
        
        if let resultsScreen = fromVC as? ResultTableViewController {
            documentService?.sendFeedback(with: resultsScreen.result)
        }
        
        if let cameraViewController = toVC as? CameraViewController,
            fromVC is MultipageReviewViewController {
            cameraViewController
                .replaceCapturedStackImages(with: documentRequests.compactMap { $0.document.previewImage })
        }
        
        return nil
    }
}

// MARK: - CameraViewControllerDelegate

extension ComponentAPICoordinator: CameraViewControllerDelegate {
    
    func camera(_ viewController: CameraViewController, didCapture document: GiniVisionDocument) {
        validate([document]) { result in
            switch result {
            case .success(let documentRequests):
                self.documentRequests.append(contentsOf: documentRequests)
                self.upload(documentRequests: documentRequests)
                
                if self.giniConfiguration.multipageEnabled, self.documentRequests.count > 1 {
                    if let imageDocument = document as? GiniImageDocument {
                        viewController.animateToControlsView(imageDocument: imageDocument)
                    }
                } else {
                    self.showNextScreenAfterPicking()
                }
            case .failure(let error):
                if let error = error as? FilePickerError, error == .maxFilesPickedCountExceeded {
                    viewController.showErrorDialog(for: error) {
                        self.showMultipageReviewScreen()
                    }
                }
            }
        }
    }
    
    func cameraDidAppear(_ viewController: CameraViewController) {
        // Here you can show the Onboarding screen in case that you decide
        // to launch it once the camera screen appears
    }
    
    func cameraDidTapMultipageReviewButton(_ viewController: CameraViewController) {
        showMultipageReviewScreen()
    }
    
    func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType) {
        switch documentPicker {
        case .gallery:
            documentPickerCoordinator.showGalleryPicker(from: viewController)
        case .explorer:
            documentPickerCoordinator.isPDFSelectionAllowed = documentRequests.isEmpty
            documentPickerCoordinator.showDocumentPicker(from: viewController)
        case .dragndrop: break
        }
    }
}

// MARK: - DocumentPickerCoordinatorDelegate

extension ComponentAPICoordinator: DocumentPickerCoordinatorDelegate {
    
    func documentPicker(_ coordinator: DocumentPickerCoordinator, didPick documents: [GiniVisionDocument]) {
        self.validate(documents) { result in
            switch result {
            case .success(let documentRequests):
                coordinator.dismissCurrentPicker {
                    self.documentRequests.append(contentsOf: documentRequests)
                    self.upload(documentRequests: documentRequests)
                    self.showNextScreenAfterPicking()
                }
            case .failure(let error):
                var positiveAction: (() -> Void)?
                
                if let error = error as? FilePickerError {
                    switch error {
                    case .maxFilesPickedCountExceeded, .mixedDocumentsUnsupported:
                        if !self.documentRequests.isEmpty {
                            positiveAction = {
                                coordinator.dismissCurrentPicker {
                                    self.showMultipageReviewScreen()
                                }
                            }
                        }
                        
                    case .photoLibraryAccessDenied:
                        break
                    }
                }

                if coordinator.currentPickerDismissesAutomatically {
                    self.cameraScreen?.showErrorDialog(for: error,
                                                       positiveAction: positiveAction)
                } else {
                    coordinator.rootViewController?.showErrorDialog(for: error,
                                                                    positiveAction: positiveAction)
                }
            }
            
        }
    }    
}

// MARK: - ReviewViewControllerDelegate

extension ComponentAPICoordinator: ReviewViewControllerDelegate {
    
    func review(_ viewController: ReviewViewController, didReview document: GiniVisionDocument) {
        if let index = documentRequests.index(of: document) {
            documentRequests[index].document = document
        }
        
        if let imageDocument = document as? GiniImageDocument {
            documentService?.update(imageDocument)
        }
    }
}

// MARK: MultipageReviewViewControllerDelegate

extension ComponentAPICoordinator: MultipageReviewViewControllerDelegate {

    func multipageReview(_ viewController: MultipageReviewViewController,
                         didSelect errorAction: NoticeActionType,
                         for documentRequest: DocumentRequest) {
        switch errorAction {
        case .retake:
            if let index = documentRequests.index(of: documentRequest.document) {
                viewController.deleteItem(at: IndexPath(row: index, section: 0), completion: {
                    self.navigationController.popViewController(animated: true)
                })
            }
        case .retry:
            if let index = documentRequests.index(of: documentRequest.document) {
                documentRequests[index].error = nil

                if self.giniConfiguration.multipageEnabled, self.documentRequests.type == .image {
                    self.refreshMultipageReview(with: self.documentRequests)
                }

                upload(documentRequests: [documentRequests[index]])
            }
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didReorder documentRequests: [DocumentRequest]) {
        self.documentRequests = documentRequests
        
        if let multipageDocumentService = documentService as? MultipageDocumentsService {
            multipageDocumentService.sortDocuments(withSameOrderAs: self.documentRequests.map { $0.document })
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didRotate documentRequest: DocumentRequest) {
        if let index = documentRequests.index(of: documentRequest.document) {
            documentRequests[index].document = documentRequest.document
        }
        
        if let imageDocument = documentRequest.document as? GiniImageDocument {
            documentService?.update(imageDocument)
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didDelete documentRequest: DocumentRequest) {
        documentService?.delete(documentRequest.document)
        documentRequests.remove(documentRequest.document)
        
        if documentRequests.isEmpty {
            navigationController.popViewController(animated: true)
        }
    }
    
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        navigationController.popViewController(animated: true)
    }
}

// MARK: NoResultsScreenDelegate

extension ComponentAPICoordinator: NoResultsScreenDelegate {
    
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        self.didTapRetry()
    }
}

// MARK: - Validation

extension ComponentAPICoordinator {
    
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

// MARK: Handle analysis results

extension ComponentAPICoordinator {
    
    fileprivate func handleAnalysis(with extractions: [String: GINIExtraction]) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = extractions.filter { payFive.contains($0.0) }.count > 0
        
        if hasPayFive {
            showResultsTableScreen(withExtractions: extractions)
        } else {
            showNoResultsScreen()
        }
    }
}
