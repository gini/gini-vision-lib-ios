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
    fileprivate let documentService: DocumentService
    fileprivate var document:GiniVisionDocument?
    fileprivate let giniColor = UIColor(red: 0, green: (157/255), blue: (220/255), alpha: 1)
    fileprivate var storyboard:UIStoryboard
    var rootViewController: UIViewController {
        return self.componentAPITabBarController
    }
    
    var childCoordinators: [Coordinator] = []
    
    fileprivate lazy var componentAPIOnboardingViewController: ComponentAPIOnboardingViewController = self.storyboard.instantiateViewController(withIdentifier: "componentAPIOnboardingViewController") as! ComponentAPIOnboardingViewController
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
    fileprivate lazy var didDocumentAnalysisComplete: DocumentAnalysisCompletion = {(result, document, error) in
        DispatchQueue.main.async {
            if let error = error {
                self.handleAnalysis(error: error)
                return
            }
            
            if let result = result,
                let document = document {
                self.handleAnalysis(result, fromDocument: document)
            }
        }
        return
    }
    
    fileprivate var cameraScreen: ComponentAPICameraViewController?
    fileprivate var reviewScreen: ComponentAPIReviewViewController?
    fileprivate var analysisScreen: ComponentAPIAnalysisViewController?
    fileprivate var resultsScreen: ResultTableViewController?
    
    init(document:GiniVisionDocument?, configuration: GiniConfiguration, documentService: DocumentService){
        self.document = document
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
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
        cameraScreen = self.storyboard.instantiateViewController(withIdentifier: "ComponentAPICamera") as? ComponentAPICameraViewController
        cameraScreen?.delegate = self
        newDocumentViewController.pushViewController(cameraScreen!, animated: true)
    }
    
    fileprivate func showReviewScreen(withDocument document: GiniVisionDocument) {
        reviewScreen = storyboard.instantiateViewController(withIdentifier: "ComponentAPIReview") as? ComponentAPIReviewViewController
        reviewScreen?.delegate = self
        reviewScreen?.document = document
        addCloseButtonIfNeeded(onViewController: reviewScreen!)
        
        // Analogouse to the Screen API the image data should be analyzed right away with the Gini SDK for iOS
        // to have results in as early as possible.
        documentService.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: didDocumentAnalysisComplete)
        
        newDocumentViewController.pushViewController(reviewScreen!, animated: true)
    }
    
    fileprivate func showAnalysisScreen(withDocument document: GiniVisionDocument) {
        analysisScreen = storyboard.instantiateViewController(withIdentifier: "ComponentAPIAnalysis") as? ComponentAPIAnalysisViewController
        analysisScreen?.delegate = self
        analysisScreen?.document = document
        addCloseButtonIfNeeded(onViewController: analysisScreen!)
        
        // In case that the view is loaded but is not analysing (i.e: user imported a PDF with the Open With feature), it should start.
        if !documentService.isAnalyzing {
            documentService.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: didDocumentAnalysisComplete)
        }
        
        newDocumentViewController.pushViewController(analysisScreen!, animated: true)
    }
    
    fileprivate func showResultsTableScreen(forDocument document: GINIDocument, withResult result:GINIResult) {
        resultsScreen = storyboard.instantiateViewController(withIdentifier: "resultScreen") as? ResultTableViewController
        resultsScreen?.result = result
        resultsScreen?.document = document
        documentService.sendFeedback(forDocument: document)
        
        newDocumentViewController.pushViewController(resultsScreen!, animated: true)
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
            let genericNoResults = storyboard.instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
            genericNoResults.delegate = self
            vc = genericNoResults
        }
        newDocumentViewController.pushViewController(vc, animated: true)
    }
    
    // MARK: Other
    fileprivate func setupTabBar() {
        let navTabBarItem = UITabBarItem(title: "New document", image: UIImage(named: "tabBarIconNewDocument"), tag: 0)
        let helpTabBarItem = UITabBarItem(title: "Help", image: UIImage(named: "tabBarIconHelp"), tag: 1)
        
        self.newDocumentViewController.tabBarItem = navTabBarItem
        self.componentAPIOnboardingViewController.tabBarItem = helpTabBarItem
        
        self.componentAPITabBarController.setViewControllers([newDocumentViewController, componentAPIOnboardingViewController], animated: true)
    }
    
    @objc fileprivate func dismissTabBarController() {
        documentService.cancelAnalysis()
        componentAPITabBarController.dismiss(animated: true, completion: nil)
        delegate?.componentAPI(coordinator: self, didFinish: ())
    }
    
    fileprivate func addCloseButtonIfNeeded(onViewController viewController: UIViewController) {
        if newDocumentViewController.viewControllers.isEmpty {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schließen", style: .plain, target: self, action: #selector(dismissTabBarController))
        }
    }
    
    fileprivate func removeFromStack(_ viewController: UIViewController) {
        var navigationStack = newDocumentViewController.viewControllers
        
        if let index = navigationStack.index(of: viewController) {
            navigationStack.remove(at: index)
            
            newDocumentViewController.setViewControllers(navigationStack, animated: false)
        }
    }
    
    func didTapRetry() {
        if (newDocumentViewController.viewControllers.flatMap { $0 as? ComponentAPICameraViewController}).first == nil {
            dismissTabBarController()
            return
        }
        _ = newDocumentViewController.popToRootViewController(animated: true)
    }
}

// MARK: UINavigationControllerDelegate

extension ComponentAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        if fromViewController is ComponentAPIReviewViewController && viewController is ComponentAPICameraViewController {
            documentService.cancelAnalysis()
        }
        
        if fromViewController is ComponentAPIAnalysisViewController && viewController is ComponentAPIReviewViewController {
            documentService.cancelAnalysis()
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
        dismissTabBarController()
    }
}

// MARK: ComponentAPIReviewScreenDelegate

extension ComponentAPICoordinator: ComponentAPIReviewViewControllerDelegate {
    func componentAPIReview(viewController: ComponentAPIReviewViewController, didReviewDocument document: GiniVisionDocument) {
        // Present already existing results retrieved from the first analysis process initiated in `viewDidLoad`.
        if let result = documentService.result,
            let document = documentService.document {
            handleAnalysis(result, fromDocument: document)
            return
        }
        
        // Restart analysis if it was canceled and is currently not running.
        if !documentService.isAnalyzing {
            if let documentData = self.document?.data {
                documentService.analyzeDocument(withData: documentData, cancelationToken: CancelationToken(), completion: didDocumentAnalysisComplete)
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
            documentService.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: didDocumentAnalysisComplete)
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
    fileprivate func handleAnalysis(_ result: GINIResult, fromDocument document: GINIDocument) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = result.filter { payFive.contains($0.0) }.count > 0
        
        if hasPayFive {
            showResultsTableScreen(forDocument: document, withResult: result)
        } else {
            showNoResultsScreen()
        }
        
        if let analysisScreen = analysisScreen {
            removeFromStack(analysisScreen)
        }
        
        if newDocumentViewController.viewControllers.count == 2 {
            if let resultsScreen = resultsScreen {
                resultsScreen.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schließen", style: .plain, target: self, action: #selector(dismissTabBarController))
            }
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
    
    @objc fileprivate func handleAnalysis(errorNotification notification: Notification) {
        let error = notification.userInfo?[GINIAnalysisManagerErrorUserInfoKey] as? NSError
        analysisScreen?.displayError(error)
    }
    
    fileprivate func handleAnalysis(error: Error) {
        analysisScreen?.displayError(error)
    }
    
    @objc fileprivate func handleAnalysis(resultNotification notification: Notification) {
        if let result = notification.userInfo?[GINIAnalysisManagerResultDictionaryUserInfoKey] as? GINIResult,
            let document = notification.userInfo?[GINIAnalysisManagerDocumentUserInfoKey] as? GINIDocument {
            handleAnalysis(result, fromDocument: document)
        } else {
            analysisScreen?.displayError(nil)
        }
    }
}





