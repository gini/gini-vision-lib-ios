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

final class ComponentAPICoordinator {
    
    fileprivate var document:GiniVisionDocument?
    fileprivate var navigationController: UINavigationController?
    fileprivate var tabBarController: UITabBarController?
    fileprivate var analysisScreen: ComponentAPIAnalysisViewController?
    fileprivate var resultsScreen: ResultTableViewController?
    fileprivate var storyboard:UIStoryboard
    
    init(document:GiniVisionDocument?){
        self.document = document
        self.storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        GiniVision.setConfiguration(giniConfiguration)
    }
    
    func start(from rootViewController:UIViewController) {
        if let tabBar = storyboard.instantiateViewController(withIdentifier: "ComponentAPI") as? UITabBarController,
            let navBar = tabBar.viewControllers?.first as? UINavigationController {
            self.tabBarController = tabBar
            self.navigationController = navBar
            if let document = document {
                if document.isReviewable {
                    showReviewScreen(withDocument: document)
                } else {
                    showAnalysisScreen(withDocument: document)
                }
            } else {
                showCameraScreen()
            }
            
            rootViewController.present(tabBar, animated: true, completion: nil)
        }
    }
    
    // MARK: Show screens
    fileprivate func showCameraScreen() {
        let cameraContainer = storyboard.instantiateViewController(withIdentifier: "ComponentAPICamera") as! ComponentAPICameraViewController
        cameraContainer.delegate = self
        navigationController?.pushViewController(cameraContainer, animated: true)
    }
    
    fileprivate func showReviewScreen(withDocument document: GiniVisionDocument) {
        let reviewContainer = storyboard.instantiateViewController(withIdentifier: "ComponentAPIReview") as! ComponentAPIReviewViewController
        reviewContainer.delegate = self
        reviewContainer.document = document
        addCloseButtonIfNeeded(onViewController: reviewContainer)
        
        // Analogouse to the Screen API the image data should be analyzed right away with the Gini SDK for iOS
        // to have results in as early as possible.
        AnalysisManager.sharedManager.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: nil)
        
        navigationController?.pushViewController(reviewContainer, animated: true)
    }
    
    fileprivate func showAnalysisScreen(withDocument document: GiniVisionDocument) {
        let analysisContainer = storyboard.instantiateViewController(withIdentifier: "ComponentAPIAnalysis") as! ComponentAPIAnalysisViewController
        analysisContainer.delegate = self
        analysisContainer.document = document
        analysisScreen = analysisContainer
        addCloseButtonIfNeeded(onViewController: analysisContainer)
        
        // In case that the view is loaded but is not analysing (i.e: user imported a PDF with the Open With feature), it should start.
        if !AnalysisManager.sharedManager.isAnalyzing {
            AnalysisManager.sharedManager.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: nil)
        }
        
        navigationController?.pushViewController(analysisContainer, animated: true)
    }
    
    fileprivate func showResultsTableScreen(forDocument document: GINIDocument, withResult result:GINIResult) {
        let vc = storyboard.instantiateViewController(withIdentifier: "resultScreen") as! ResultTableViewController
        vc.result = result
        vc.document = document
        resultsScreen = vc
        navigationController?.pushViewController(vc, animated: true)
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
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Other
    @objc fileprivate func dismissTabBarController() {
        AnalysisManager.sharedManager.cancelAnalysis()
        tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func addCloseButtonIfNeeded(onViewController viewController: UIViewController) {
        if let navBar = navigationController, navBar.viewControllers.isEmpty {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schließen", style: .plain, target: self, action: #selector(dismissTabBarController))
        }
    }
    
    fileprivate func removeFromStack(_ viewController: UIViewController) {
        if var navigationStack = navigationController?.viewControllers,
            let index = navigationStack.index(of: viewController) {
            navigationStack.remove(at: index)
            
            navigationController?.setViewControllers(navigationStack, animated: false)
        }
    }
}

// MARK: ComponentAPICameraScreenDelegate

extension ComponentAPICoordinator: ComponentAPICameraScreenDelegate {
    func didPick(document: GiniVisionDocument) {
        if document.isReviewable {
            showReviewScreen(withDocument: document)
        } else {
            showAnalysisScreen(withDocument: document)
        }
    }
    
    func didTapClose() {
        dismissTabBarController()
    }
}

// MARK: ComponentAPIReviewScreenDelegate

extension ComponentAPICoordinator: ComponentAPIReviewScreenDelegate {
    
    func didReview(documentReviewed: GiniVisionDocument) {
        if documentReviewed.data != document?.data {
            document = documentReviewed
            if let documentData = document?.data {
                AnalysisManager.sharedManager.analyzeDocument(withData: documentData, cancelationToken: CancelationToken(), completion: nil)
                showAnalysisScreen(withDocument: documentReviewed)
            }
            return
        }
        
        // Present already existing results retrieved from the first analysis process initiated in `viewDidLoad`.
        if let result = AnalysisManager.sharedManager.result,
            let document = AnalysisManager.sharedManager.document {
            handleAnalysis(result, fromDocument: document)
            return
        }
        
        // Restart analysis if it was canceled and is currently not running.
        if !AnalysisManager.sharedManager.isAnalyzing {
            if let documentData = document?.data {
                AnalysisManager.sharedManager.analyzeDocument(withData: documentData, cancelationToken: CancelationToken(), completion: nil)
            }
        }
        
        showAnalysisScreen(withDocument: documentReviewed)
    }
    
    func didCancelReview() {
        AnalysisManager.sharedManager.cancelAnalysis()
    }
}

// MARK: ComponentAPIAnalysisScreenDelegate

extension ComponentAPICoordinator: ComponentAPIAnalysisScreenDelegate {
    func didTapErrorButton() {
        if let document = document {
            AnalysisManager.sharedManager.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: nil)
        }
    }
    
    func didCancelAnalysis() {
        AnalysisManager.sharedManager.cancelAnalysis()
    }
    
    func didAppear() {
        // Subscribe to analysis events which will be fired when the analysis process ends.
        // Either with a valid result or an error.
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnalysis(errorNotification:)), name: NSNotification.Name(rawValue: GINIAnalysisManagerDidReceiveErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnalysis(resultNotification:)), name: NSNotification.Name(rawValue: GINIAnalysisManagerDidReceiveResultNotification), object: nil)
        
        // Because results may come in during view controller transition,
        // check for already existent results in shared analysis manager.
        handleExistingResults()
    }
    
    func didDisappear() {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: NoResultsScreenDelegate

extension ComponentAPICoordinator: NoResultsScreenDelegate {
    func didTapRetry() {
        if let navVC = navigationController, navVC.viewControllers.count != 1 {
            _ = navVC.popToRootViewController(animated: true)
        } else {
            dismissTabBarController()
        }
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
        
        if navigationController?.viewControllers.count == 2 {
            if let resultsScreen = resultsScreen {
                resultsScreen.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schließen", style: .plain, target: self, action: #selector(dismissTabBarController))
            }
        }
    }
    
    fileprivate func handleExistingResults() {
        if let result = AnalysisManager.sharedManager.result,
            let document = AnalysisManager.sharedManager.document {
            handleAnalysis(result, fromDocument: document)
        } else if let error = AnalysisManager.sharedManager.error {
            analysisScreen?.displayError(error)
        }
    }
    
    @objc fileprivate func handleAnalysis(errorNotification notification: Notification) {
        let error = notification.userInfo?[GINIAnalysisManagerErrorUserInfoKey] as? NSError
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





