//
//  ScreenAPICoordinator.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniVision
import Gini_iOS_SDK

protocol ScreenAPICoordinatorDelegate: class {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish:())
}

final class ScreenAPICoordinator: NSObject, Coordinator {
    
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController
    }
    var screenAPIViewController: UINavigationController!
    
    let documentService: DocumentService
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocument: GiniVisionDocument?
    var visionConfiguration: GiniConfiguration
    
    init(configuration: GiniConfiguration,
         importedDocument document: GiniVisionDocument?,
         documentService: DocumentService) {
        self.visionConfiguration = configuration
        self.visionDocument = document
        self.documentService = documentService
    }
    
    func start() {
        let viewController = GiniVision.viewController(withDelegate: self,
                                                       withConfiguration: visionConfiguration,
                                                       importedDocument: visionDocument)
        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.navigationBar.barTintColor = visionConfiguration.navigationBarTintColor
        screenAPIViewController.navigationBar.tintColor = visionConfiguration.navigationBarTitleColor
        screenAPIViewController.setNavigationBarHidden(true, animated: false)
        screenAPIViewController.delegate = self
        screenAPIViewController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(visionDocument document: GiniVisionDocument) {
        cancelAnalysis()
        visionDocument = document
        
        documentService.analyzeDocument(withData: document.data,
                                        cancelationToken: CancelationToken()) { [weak self] result, document, error in
            if let analysisDelegate = self?.analysisDelegate {
                DispatchQueue.main.async {
                    guard let document = document, let result = result else {
                        if let error = error, let analysisDelegate = self?.analysisDelegate {
                            self?.show(error: error, analysisDelegate: analysisDelegate)
                            return
                        }
                        return
                    }
                    self?.present(result: result, fromDocument: document, analysisDelegate: analysisDelegate)
                }
            }
        }
    }
    
    func cancelAnalysis() {
        documentService.cancelAnalysis()
        visionDocument = nil
        analysisDelegate = nil
    }
    
    // MARK: Handle results from analysis process
    func show(error: Error, analysisDelegate: AnalysisDelegate?) {
        guard let document = self.visionDocument else {
            return
        }
        let errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
        
        // Display an error with a custom message and custom action on the analysis screen
        analysisDelegate?.displayError(withMessage: errorMessage, andAction: { [weak self] in
            self?.analyzeDocument(visionDocument: document)
        })
    }
    
    func present(result: GINIResult, fromDocument document: GINIDocument, analysisDelegate: AnalysisDelegate?) {
        let resultParameters = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        
        if hasExtactions {
            showResultsScreen(analysisDelegate: analysisDelegate)
        } else {
            showNoResultsScreen(analysisDelegate: analysisDelegate)
        }
    }
    
    fileprivate func showResultsScreen(analysisDelegate: AnalysisDelegate?) {
        let customResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "resultScreen") as? ResultTableViewController)!
        customResultsScreen.result = documentService.result
        customResultsScreen.document = documentService.document
        
        DispatchQueue.main.async { [weak self] in
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
        }
    }
    
    fileprivate func showNoResultsScreen(analysisDelegate: AnalysisDelegate?) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self, let analysisDelegate = analysisDelegate else { return }
            let shown = analysisDelegate.tryDisplayNoResultsScreen()
            if !shown {
                let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
                customNoResultsScreen.delegate = self
                self.screenAPIViewController.setNavigationBarHidden(false, animated: false)
                self.screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
            }
        }
    }
    
}

// MARK: UINavigationControllerDelegate

extension ScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Since the NoResultViewController and ResultTableViewController are in the navigation stack,
        // when it is necessary to go back, it dismiss the ScreenAPI so the Analysis screen is not shown again
        
        if fromVC is NoResultViewController {
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
        }
        
        if fromVC is ResultTableViewController {
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
            if let document = documentService.document {
                self.documentService.sendFeedback(forDocument: document)
            }
        }
        
        return nil
    }
}

// MARK: NoResultsScreenDelegate

extension ScreenAPICoordinator: NoResultsScreenDelegate {
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        screenAPIViewController.popToRootViewController(animated: true)
    }
}

// MARK: GiniVisionDelegate

extension ScreenAPICoordinator: GiniVisionDelegate {
    
    func didCapture(document: GiniVisionDocument) {
        // Analyze document data right away with the Gini SDK for iOS to have results in as early as possible.
        self.analyzeDocument(visionDocument: document)
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        // Analyze reviewed document when changes were made by the user during review or
        // there is no result and is not analysing.
        if changes || (!documentService.isAnalyzing && documentService.result == nil) {
            self.analyzeDocument(visionDocument: document)
            
            return
        }
    }
    
    func didCancelCapturing() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    // Optional delegate methods
    func didCancelReview() {
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalysis()
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
        self.analysisDelegate = analysisDelegate
        
        // if there is already results, present them
        if let result = documentService.result,
            let document = documentService.document {
            present(result: result, fromDocument: document, analysisDelegate: analysisDelegate)
        }
        
        // The analysis screen is where the user should be confronted with
        // any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let error = documentService.error {
            show(error: error, analysisDelegate: analysisDelegate)
        }
    }
    
    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalysis()
    }
    
}
