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
    fileprivate var document: GiniVisionDocument?
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
        return navBarViewController
    }()
    fileprivate lazy var componentAPITabBarController: UITabBarController = {
        let tabBarViewController = UITabBarController()
        tabBarViewController.tabBar.barTintColor = self.giniColor
        tabBarViewController.tabBar.tintColor = .white
        
        if #available(iOS 10.0, *) {
            tabBarViewController.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
        }
        
        return tabBarViewController
    }()
    
    fileprivate(set) var cameraScreen: CameraViewController?
    fileprivate(set) var reviewScreen: ComponentAPIReviewViewController?
    fileprivate(set) var analysisScreen: ComponentAPIAnalysisViewController?
    fileprivate(set) var resultsScreen: ResultTableViewController?
    fileprivate(set) lazy var documentPickerCoordinator = DocumentPickerCoordinator(giniConfiguration: giniConfiguration)

    init(document: GiniVisionDocument?,
         configuration: GiniConfiguration,
         client: GiniClient) {
        self.document = document
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
        
        if let document = document {
            if document.isReviewable {
                showReviewScreen(withDocument: document)
            } else {
                showAnalysisScreen(withDocument: document)
            }
        } else {
            showCameraScreen()
        }
    }
    
    // MARK: Show screens
    fileprivate func showCameraScreen() {
        cameraScreen = CameraViewController(giniConfiguration: giniConfiguration)
        cameraScreen?.delegate = self
        cameraScreen?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schließen",
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(closeComponentAPI))

        if giniConfiguration.fileImportSupportedTypes != .none {
            documentPickerCoordinator.delegate = self
            
            if documentPickerCoordinator.isGalleryPermissionGranted {
                documentPickerCoordinator.startCaching()
            }
            
            if #available(iOS 11.0, *) {
                documentPickerCoordinator.setupDragAndDrop(in: cameraScreen!.view)
            }
        }
        navigationController.pushViewController(cameraScreen!, animated: true)
    }
    
    fileprivate func showReviewScreen(withDocument document: GiniVisionDocument) {
        reviewScreen = storyboard.instantiateViewController(withIdentifier: "ComponentAPIReview")
            as? ComponentAPIReviewViewController
        reviewScreen?.delegate = self
        reviewScreen?.document = document
        reviewScreen?.giniConfiguration = giniConfiguration
        addCloseButtonIfNeeded(onViewController: reviewScreen!)
        
        
        navigationController.pushViewController(reviewScreen!, animated: true)
    }
    
    fileprivate func showAnalysisScreen(withDocument document: GiniVisionDocument) {
        analysisScreen = storyboard.instantiateViewController(withIdentifier: "ComponentAPIAnalysis")
            as? ComponentAPIAnalysisViewController
        analysisScreen?.delegate = self
        analysisScreen?.document = document
        addCloseButtonIfNeeded(onViewController: analysisScreen!)
        
        navigationController.pushViewController(analysisScreen!, animated: true)
    }
    
    fileprivate func showResultsTableScreen(forDocument document: GINIDocument,
                                            withResult result: [String: GINIExtraction]) {
        resultsScreen = storyboard.instantiateViewController(withIdentifier: "resultScreen")
            as? ResultTableViewController
        resultsScreen?.result = result
        resultsScreen?.document = document
        
        if navigationController.viewControllers.first is ComponentAPIAnalysisViewController {
            resultsScreen!.navigationItem
                .rightBarButtonItem = UIBarButtonItem(title: "Schließen",
                                                      style: .plain,
                                                      target: self,
                                                      action: #selector(closeComponentAPIFromResults))
        }
        
        push(viewController: resultsScreen!, removingViewControllerOfType: ComponentAPIAnalysisViewController.self)
        analysisScreen = nil
    }
    
    fileprivate func showNoResultsScreen() {
        let vc: UIViewController
        if document?.type == .image {
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
        
        push(viewController: vc, removingViewControllerOfType: ComponentAPIAnalysisViewController.self)
        analysisScreen = nil

    }
    
    // MARK: Other
    fileprivate func setupTabBar() {
        let navTabBarItem = UITabBarItem(title: "New document", image: UIImage(named: "tabBarIconNewDocument"), tag: 0)
        let helpTabBarItem = UITabBarItem(title: "Help", image: UIImage(named: "tabBarIconHelp"), tag: 1)
        
        self.navigationController.tabBarItem = navTabBarItem
        self.componentAPIOnboardingViewController.tabBarItem = helpTabBarItem
        
        self.componentAPITabBarController.setViewControllers([navigationController,
                                                              componentAPIOnboardingViewController],
                                                             animated: true)
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
    
    fileprivate func addCloseButtonIfNeeded(onViewController viewController: UIViewController) {
        if navigationController.viewControllers.isEmpty {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schließen",
                                                                              style: .plain,
                                                                              target: self,
                                                                              action: #selector(closeComponentAPI))
        }
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
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard let fromViewController = navigationController
            .transitionCoordinator?.viewController(forKey: .from) else { return }
        
        if fromViewController is ReviewViewController &&
            viewController is CameraViewController {
            reviewScreen = nil
            documentService?.cancelAnalysis()
        }
        
        if fromViewController is ComponentAPIAnalysisViewController &&
            viewController is ReviewViewController {
            analysisScreen = nil
            documentService?.cancelAnalysis()
        }
        
        if let resultsScreen = fromViewController as? ResultTableViewController {
            documentService?.sendFeedback(with: resultsScreen.result)
        }
    }
}

extension ComponentAPICoordinator: CameraViewControllerDelegate {
    func camera(_ viewController: CameraViewController, didCapture document: GiniVisionDocument) {
        if document.isReviewable {
            showReviewScreen(withDocument: document)
        } else {
            showAnalysisScreen(withDocument: document)
        }
    }
    
    func cameraDidAppear(_ viewController: CameraViewController) {
        
    }
    
    func cameraDidTapMultipageReviewButton(_ viewController: CameraViewController) {
        
    }
    
    func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType) {
        switch documentPicker {
        case .gallery:
            documentPickerCoordinator.showGalleryPicker(from: viewController)
        case .explorer:
            documentPickerCoordinator.isPDFSelectionAllowed = true
            documentPickerCoordinator.showDocumentPicker(from: viewController)
        case .dragndrop: break
        }
    }
}

// MARK: - DocumentPickerCoordinatorDelegate

extension ComponentAPICoordinator: DocumentPickerCoordinatorDelegate {
    func documentPicker(_ coordinator: DocumentPickerCoordinator, didPick documents: [GiniVisionDocument]) {
        
    }    
}

// MARK: ComponentAPIReviewScreenDelegate

extension ComponentAPICoordinator: ReviewViewControllerDelegate {
    func review(_ viewController: ReviewViewController, didReview document: GiniVisionDocument) {
        self.document = document
        documentService?.cancelAnalysis()
    }
}

// MARK: ComponentAPIAnalysisScreenDelegate

extension ComponentAPICoordinator: ComponentAPIAnalysisViewControllerDelegate {    
    func componentAPIAnalysis(viewController: ComponentAPIAnalysisViewController, didTapErrorButton: ()) {
        
    }
}

// MARK: NoResultsScreenDelegate

extension ComponentAPICoordinator: NoResultsScreenDelegate {
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        self.didTapRetry()
    }
}

// MARK: Handle analysis results

extension ComponentAPICoordinator {
    fileprivate func handleAnalysis(_ result: [String: GINIExtraction], fromDocument document: GINIDocument) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = result.filter { payFive.contains($0.0) }.count > 0
        
        if hasPayFive {
            showResultsTableScreen(forDocument: document, withResult: result)
        } else {
            showNoResultsScreen()
        }
    }
    
    fileprivate func handleAnalysis(error: Error) {
        analysisScreen?.displayError(error)
    }
}
