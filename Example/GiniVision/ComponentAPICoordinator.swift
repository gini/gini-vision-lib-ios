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
    
    fileprivate let documentService: DocumentService
    fileprivate var document: GiniVisionDocument?
    fileprivate let giniColor = UIColor(red: 0, green: (157/255), blue: (220/255), alpha: 1)
    
    fileprivate lazy var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    fileprivate lazy var componentAPIOnboardingViewController: ComponentAPIOnboardingViewController =
        (self.storyboard.instantiateViewController(withIdentifier: "componentAPIOnboardingViewController")
            as? ComponentAPIOnboardingViewController)!
    fileprivate lazy var newDocumentViewController: UINavigationController = {
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
    fileprivate var didDocumentAnalysisComplete: DocumentAnalysisCompletion {
        return {(result, document, error) in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.handleAnalysis(error: error)
                    return
                }
                
                if let result = result,
                    let document = document,
                    self?.analysisScreen != nil {
                    self?.handleAnalysis(result, fromDocument: document)
                }
            }
        }
    }
    
    fileprivate(set) var cameraScreen: ComponentAPICameraViewController?
    fileprivate(set) var reviewScreen: ComponentAPIReviewViewController?
    fileprivate(set) var analysisScreen: ComponentAPIAnalysisViewController?
    fileprivate(set) var resultsScreen: ResultTableViewController?
    
    init(document: GiniVisionDocument?,
         configuration: GiniConfiguration,
         documentService: DocumentService) {
        self.document = document
        self.documentService = documentService
        GiniVision.setConfiguration(configuration)
    }
    
    func start() {
        self.setupTabBar()
        self.newDocumentViewController.delegate = self
        
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
        cameraScreen = self.storyboard.instantiateViewController(withIdentifier: "ComponentAPICamera")
            as? ComponentAPICameraViewController
        cameraScreen?.delegate = self
        newDocumentViewController.pushViewController(cameraScreen!, animated: true)
    }
    
    fileprivate func showReviewScreen(withDocument document: GiniVisionDocument) {
        reviewScreen = storyboard.instantiateViewController(withIdentifier: "ComponentAPIReview")
            as? ComponentAPIReviewViewController
        reviewScreen?.delegate = self
        reviewScreen?.document = document
        addCloseButtonIfNeeded(onViewController: reviewScreen!)
        
        // Analogouse to the Screen API the image data should be analyzed right away with the Gini SDK for iOS
        // to have results in as early as possible.
        documentService.analyzeDocument(withData: document.data,
                                        cancelationToken: CancelationToken(),
                                        completion: didDocumentAnalysisComplete)
        
        newDocumentViewController.pushViewController(reviewScreen!, animated: true)
    }
    
    fileprivate func showAnalysisScreen(withDocument document: GiniVisionDocument) {
        analysisScreen = storyboard.instantiateViewController(withIdentifier: "ComponentAPIAnalysis")
            as? ComponentAPIAnalysisViewController
        analysisScreen?.delegate = self
        analysisScreen?.document = document
        addCloseButtonIfNeeded(onViewController: analysisScreen!)
        
        // In case that the view is loaded but is not analysing (i.e: user imported a PDF with
        // the Open With feature), it should start.
        if !documentService.isAnalyzing {
            documentService.analyzeDocument(withData: document.data,
                                            cancelationToken: CancelationToken(),
                                            completion: didDocumentAnalysisComplete)
        }
        
        newDocumentViewController.pushViewController(analysisScreen!, animated: true)
    }
    
    fileprivate func showResultsTableScreen(forDocument document: GINIDocument,
                                            withResult result: [String: GINIExtraction]) {
        resultsScreen = storyboard.instantiateViewController(withIdentifier: "resultScreen")
            as? ResultTableViewController
        resultsScreen?.result = result
        resultsScreen?.document = document
        
        if newDocumentViewController.viewControllers.first is ComponentAPIAnalysisViewController {
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
        
        self.newDocumentViewController.tabBarItem = navTabBarItem
        self.componentAPIOnboardingViewController.tabBarItem = helpTabBarItem
        
        self.componentAPITabBarController.setViewControllers([newDocumentViewController,
                                                              componentAPIOnboardingViewController],
                                                             animated: true)
    }
    
    @objc fileprivate func closeComponentAPI() {
        documentService.cancelAnalysis()
        delegate?.componentAPI(coordinator: self, didFinish: ())
    }
    
    @objc fileprivate func closeComponentAPIFromResults() {
        if let document = resultsScreen?.document {
            documentService.sendFeedback(forDocument: document)
        }
        closeComponentAPI()
    }
    
    fileprivate func addCloseButtonIfNeeded(onViewController viewController: UIViewController) {
        if newDocumentViewController.viewControllers.isEmpty {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schließen",
                                                                              style: .plain,
                                                                              target: self,
                                                                              action: #selector(closeComponentAPI))
        }
    }
    
    fileprivate func push<T>(viewController: UIViewController, removingViewControllerOfType: T.Type) {
        var navigationStack = newDocumentViewController.viewControllers
        
        if let deleteViewController = (navigationStack.compactMap { $0 as? T }.first) as? UIViewController,
            let index = navigationStack.index(of: deleteViewController) {
            navigationStack.remove(at: index)
        }
        navigationStack.append(viewController)
        newDocumentViewController.setViewControllers(navigationStack, animated: true)
    }
    
    func didTapRetry() {
        if (newDocumentViewController.viewControllers.compactMap { $0 as? ComponentAPICameraViewController}).first == nil {
            closeComponentAPI()
            return
        }

        newDocumentViewController.popToRootViewController(animated: true)
    }
}

// MARK: UINavigationControllerDelegate

extension ComponentAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard let fromViewController = navigationController
            .transitionCoordinator?.viewController(forKey: .from) else { return }
        newDocumentViewController
            .setNavigationBarHidden(viewController is ComponentAPICameraViewController, animated: true)
        
        if fromViewController is ComponentAPIReviewViewController &&
            viewController is ComponentAPICameraViewController {
            reviewScreen = nil
            documentService.cancelAnalysis()
        }
        
        if fromViewController is ComponentAPIAnalysisViewController &&
            viewController is ComponentAPIReviewViewController {
            analysisScreen = nil
            documentService.cancelAnalysis()
        }
        
        if let resultsScreen = fromViewController as? ResultTableViewController {
            documentService.sendFeedback(forDocument: resultsScreen.document)
        }
    }
}

// MARK: ComponentAPICameraScreenDelegate

extension ComponentAPICoordinator: ComponentAPICameraViewControllerDelegate {
    func componentAPICamera(viewController: UIViewController, didPickDocument document: GiniVisionDocument) {
        if document.isReviewable {
            showReviewScreen(withDocument: document)
        } else {
            showAnalysisScreen(withDocument: document)
        }
    }
    
    func componentAPICamera(viewController: UIViewController, didTapClose: ()) {
        closeComponentAPI()
    }
}

// MARK: ComponentAPIReviewScreenDelegate

extension ComponentAPICoordinator: ComponentAPIReviewViewControllerDelegate {
    func componentAPIReview(viewController: ComponentAPIReviewViewController,
                            didReviewDocument document: GiniVisionDocument) {
        // Present already existing results retrieved from the first analysis process initiated in `viewDidLoad`.
        if let result = documentService.result,
            let document = documentService.document {
            handleAnalysis(result, fromDocument: document)
            return
        }
        
        // Restart analysis if it was canceled and is currently not running.
        if !documentService.isAnalyzing {
            if let documentData = self.document?.data {
                documentService.analyzeDocument(withData: documentData,
                                                cancelationToken: CancelationToken(),
                                                completion: didDocumentAnalysisComplete)
            }
        }
        
        showAnalysisScreen(withDocument: document)
    }
    
    func componentAPIReview(viewController: ComponentAPIReviewViewController, didRotate document: GiniVisionDocument) {
        self.document = document
        documentService.cancelAnalysis()
    }
}

// MARK: ComponentAPIAnalysisScreenDelegate

extension ComponentAPICoordinator: ComponentAPIAnalysisViewControllerDelegate {    
    func componentAPIAnalysis(viewController: ComponentAPIAnalysisViewController, didTapErrorButton: ()) {
        if let document = document {
            documentService.analyzeDocument(withData: document.data,
                                            cancelationToken: CancelationToken(),
                                            completion: didDocumentAnalysisComplete)
        }
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
    
    fileprivate func handleExistingResults() {
        if let result = documentService.result,
            let document = documentService.document {
            handleAnalysis(result, fromDocument: document)
        } else if let error = documentService.error {
            analysisScreen?.displayError(error)
        }
    }
    
    fileprivate func handleAnalysis(error: Error) {
        analysisScreen?.displayError(error)
    }
}
