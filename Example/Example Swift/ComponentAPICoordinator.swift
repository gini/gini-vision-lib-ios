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
    
    fileprivate var documentService: ComponentAPIDocumentServiceProtocol?
    fileprivate var pages: [GiniVisionPage]
    // When there was an error uploading a document or analyzing it and the analysis screen
    // had not been initialized yet, both the error message and action has to be saved to show in the analysis screen.
    fileprivate var analysisErrorAndAction: (message: String, action: () -> Void)?
    
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
        let multipageReviewScreen = MultipageReviewViewController(pages: pages,
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
    
    init(pages: [GiniVisionPage],
         configuration: GiniConfiguration,
         documentService: ComponentAPIDocumentServiceProtocol) {
        self.pages = pages
        self.giniConfiguration = configuration
        self.documentService = documentService
        super.init()
        
        GiniVision.setConfiguration(configuration)
    }
    
    func start() {
        self.setupTabBar()
        self.navigationController.delegate = self
        
        if pages.isEmpty {
            showCameraScreen()
        } else {
            if pages.type == .image {
                if giniConfiguration.multipageEnabled {
                    showMultipageReviewScreen()
                } else {
                    showReviewScreen()
                }
                
                pages.forEach { process(captured: $0)}
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
        guard let document = pages.first?.document else { return }
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
        guard let page = pages.first else { return }
        
        analysisScreen = AnalysisViewController(document: page.document)
        
        if let (message, action) = analysisErrorAndAction {
            showErrorInAnalysisScreen(with: message, action: action)
        }
        
        if pages.type == .image {
            // In multipage mode the analysis can be triggered once the documents have been uploaded.
            // However, in single mode, the analysis can be triggered right after capturing the image.
            // That is why the document upload should be done here and start the analysis afterwards
            if giniConfiguration.multipageEnabled {
                self.startAnalysis()
            } else {
                self.uploadAndStartAnalysis(for: page)
            }
        }
        
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
        
        push(viewController: resultsScreen!, removing: [reviewScreen, analysisScreen])
    }
    
    fileprivate func showNoResultsScreen() {
        let vc: UIViewController
        if pages.type == .image {
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
        
        push(viewController: vc, removing: [reviewScreen, analysisScreen])
        
    }
    
    fileprivate func showNextScreenAfterPicking() {
        if let documentsType = pages.type {
            switch documentsType {
            case .image:                
                if giniConfiguration.multipageEnabled {
                    refreshMultipageReview(with: self.pages)
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
        delegate?.componentAPI(coordinator: self, didFinish: ())
    }
    
    @objc fileprivate func closeComponentAPIFromResults() {
        if let results = resultsScreen?.result {
            documentService?.sendFeedback(with: results)
        }
        closeComponentAPI()
    }
    
    fileprivate func push<T: UIViewController>(viewController: UIViewController, removing viewControllers: [T?]) {
        var navigationStack = navigationController.viewControllers
        let viewControllersToDelete = navigationStack.filter {
            return viewControllers
                .lazy
                .compactMap { $0 }
                .contains($0)
        }
        
        viewControllersToDelete.forEach { viewControllerToDelete in
            if let index = navigationStack.index(of: viewControllerToDelete) {
                navigationStack.remove(at: index)
            }
        }
        
        navigationStack.append(viewController)
        navigationController.setViewControllers(navigationStack, animated: true)
    }
    
    fileprivate func refreshMultipageReview(with pages: [GiniVisionPage]) {
        multipageReviewScreen.navigationItem
            .rightBarButtonItem?
            .isEnabled = pages
                .reduce(true, { result, page in
                    result && page.isUploaded
                })
        multipageReviewScreen.updateCollections(with: pages)
    }
}

// MARK: - Networking

extension ComponentAPICoordinator {
    fileprivate func upload(page: GiniVisionPage,
                            didComplete: @escaping () -> Void,
                            didFail: @escaping ( Error) -> Void) {
        self.documentService?.upload(document: page.document) { result in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let index = self.pages
                    .index(of: page.document) else { return }
                switch result {
                case .success:
                    self.pages[index].isUploaded = true
                    didComplete()
                case .failure(let error):
                    self.pages[index].error = error
                    didFail(error)
                }
            }
        }
    }
    
    fileprivate func uploadAndStartAnalysis(for page: GiniVisionPage) {
        self.upload(page: page, didComplete: {
            self.startAnalysis()
        }, didFail: { error in
            guard let error = error as? GiniVisionError else { return }
            self.showErrorInAnalysisScreen(with: error.message) {
                self.uploadAndStartAnalysis(for: page)
            }
        })
    }
    
    private func process(captured page: GiniVisionPage) {
        if !page.document.isReviewable {
            uploadAndStartAnalysis(for: page)
        } else if giniConfiguration.multipageEnabled {
            let refreshMultipageScreen = {
                // When multipage mode is used and documents are images, you have to refresh the multipage review screen
                if self.giniConfiguration.multipageEnabled, self.pages.type == .image {
                    self.refreshMultipageReview(with: self.pages)
                }
            }
            upload(page: page,
                   didComplete: refreshMultipageScreen,
                   didFail: { _ in refreshMultipageScreen()})
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
                    guard let firstPage = self.pages.first else { return }
                    let visionError = CustomAnalysisError.analysisFailed
                    self.showErrorInAnalysisScreen(with: visionError.message) {
                        self.startAnalysis()
                    }
                }
            }
        })
    }
    
    fileprivate func delete(document: GiniVisionDocument) {
        documentService?.remove(document: document)
    }
    
    private func showErrorInAnalysisScreen(with message: String,
                                           action: @escaping () -> Void) {
        if let analysisScreen = analysisScreen {
            self.analysisScreen?.showError(with: message) { [weak self] in
                guard let `self` = self else { return }
                self.analysisErrorAndAction = nil
                action()
            }
        } else {
            self.analysisErrorAndAction = (message, action)
        }

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
            if let document = pages.first?.document {
                documentService?.remove(document: document)
            }
        }
        
        if fromVC is AnalysisViewController {
            analysisScreen = nil
            if operation == .pop {
                documentService?.cancelAnalysis()
            }
        }
        
        if toVC is CameraViewController &&
            (fromVC is ReviewViewController ||
             fromVC is AnalysisViewController ||
             fromVC is ImageAnalysisNoResultsViewController) {
            // When going directly from the analysis or from the single page review screen to the camera the pages
            // collection should be cleared, since the document processed in that cases is not going to be reused
            pages.removeAll()
            documentService?.resetToInitialState()
        }
        
        if let resultsScreen = fromVC as? ResultTableViewController {
            documentService?.sendFeedback(with: resultsScreen.result)
            closeComponentAPI()
        }
        
        if let cameraViewController = toVC as? CameraViewController, fromVC is MultipageReviewViewController {
            cameraViewController
                .replaceCapturedStackImages(with: pages.compactMap { $0.document.previewImage })
        }
        
        return nil
    }
}

// MARK: - CameraViewControllerDelegate

extension ComponentAPICoordinator: CameraViewControllerDelegate {
    
    func camera(_ viewController: CameraViewController, didCapture document: GiniVisionDocument) {
        validate([document]) { result in
            switch result {
            case .success(let validatedPages):
                guard let validatedPage = validatedPages.first else { return }
                self.pages.append(contentsOf: validatedPages)
                self.process(captured: validatedPage)
                
                // In case that there is more than one image already captured, an animation is shown instead of
                // going to next screen
                if let imageDocument = document as? GiniImageDocument, self.pages.count > 1 {
                    viewController.animateToControlsView(imageDocument: imageDocument)
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
            documentPickerCoordinator.isPDFSelectionAllowed = pages.isEmpty
            documentPickerCoordinator.showDocumentPicker(from: viewController)
        }
    }
}

// MARK: - DocumentPickerCoordinatorDelegate

extension ComponentAPICoordinator: DocumentPickerCoordinatorDelegate {
    
    func documentPicker(_ coordinator: DocumentPickerCoordinator, didPick documents: [GiniVisionDocument]) {
        self.validate(documents) { result in
            switch result {
            case .success(let validatedPages):
                coordinator.dismissCurrentPicker {
                    self.pages.append(contentsOf: validatedPages)
                    self.pages.forEach { self.process(captured: $0)}
                    self.showNextScreenAfterPicking()
                }
            case .failure(let error):
                var positiveAction: (() -> Void)?
                
                if let error = error as? FilePickerError {
                    switch error {
                    case .maxFilesPickedCountExceeded, .mixedDocumentsUnsupported:
                        if !self.pages.isEmpty {
                            positiveAction = {
                                coordinator.dismissCurrentPicker {
                                    if self.giniConfiguration.multipageEnabled {
                                        self.showMultipageReviewScreen()
                                    } else {
                                        self.showReviewScreen()
                                    }
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
                    coordinator.currentPickerViewController?.showErrorDialog(for: error,
                                                                             positiveAction: positiveAction)
                }
            }
            
        }
    }    
}

// MARK: - ReviewViewControllerDelegate

extension ComponentAPICoordinator: ReviewViewControllerDelegate {
    
    func review(_ viewController: ReviewViewController, didReview document: GiniVisionDocument) {
        if let index = pages.index(of: document) {
            pages[index].document = document
        }
        
        if let imageDocument = document as? GiniImageDocument {
            documentService?.update(imageDocument: imageDocument)
        }
    }
}

// MARK: MultipageReviewViewControllerDelegate

extension ComponentAPICoordinator: MultipageReviewViewControllerDelegate {
    
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didTapRetryUploadFor page: GiniVisionPage) {
        if let index = pages.index(of: page.document) {
            pages[index].error = nil
            
            if self.giniConfiguration.multipageEnabled, self.pages.type == .image {
                self.refreshMultipageReview(with: self.pages)
            }
            
            self.pages.forEach { self.process(captured: $0)}
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didReorder pages: [GiniVisionPage]) {
        self.pages = pages
        
        if giniConfiguration.multipageEnabled {
            documentService?.sortDocuments(withSameOrderAs: self.pages.map { $0.document })
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didRotate page: GiniVisionPage) {
        if let index = pages.index(of: page.document) {
            pages[index].document = page.document
        }
        
        if let imageDocument = page.document as? GiniImageDocument {
            documentService?.update(imageDocument: imageDocument)
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didDelete page: GiniVisionPage) {
        documentService?.remove(document: page.document)
        pages.remove(page.document)
        
        if pages.isEmpty {
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
                              completion: @escaping (CompletionResult<[GiniVisionPage]>) -> Void) {
        guard !(documents + pages.map {$0.document}).containsDifferentTypes else {
            completion(.failure(FilePickerError.mixedDocumentsUnsupported))
            return
        }
        
        guard (documents.count + pages.count) <= GiniVisionDocumentValidator.maxPagesCount else {
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
                          completion: @escaping ([GiniVisionPage]) -> Void) {
        DispatchQueue.global().async {
            var pages: [GiniVisionPage] = []
            documents.forEach { document in
                var documentError: Error?
                do {
                    try GiniVisionDocumentValidator.validate(document,
                                                             withConfig: self.giniConfiguration)
                } catch let error {
                    documentError = error
                }
                
                pages.append(GiniVisionPage(document: document, error: documentError))
            }
            
            DispatchQueue.main.async {
                completion(pages)
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
