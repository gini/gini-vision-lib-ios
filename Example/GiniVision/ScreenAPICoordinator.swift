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
    var errorMessage: String?
    
    lazy var didDocumentAnalysisFinished: DocumentAnalysisCompletion = { [weak self] result, document, error in
        guard let document = document, let result = result else {
            if let error = error, self?.analysisDelegate != nil {
                self?.errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
                self?.show(errorMessage: (self?.errorMessage)!)
                return
            }
            return
        }
        if ((self?.visionDocument as? GiniQRCodeDocument) != nil) || self?.analysisDelegate != nil {
            self?.show(result: result, fromDocument: document)
        }
    }
    
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
    func analyzeDocument(visionDocument document: GiniVisionDocument, completion: @escaping DocumentAnalysisCompletion) {
        cancelAnalsyis()
        visionDocument = document
        
        documentService.analyzeDocument(withData: document.data,
                                        cancelationToken: CancelationToken(),
                                        completion: completion)
    }
    
    func cancelAnalsyis() {
        documentService.cancelAnalysis()
        errorMessage = nil
        visionDocument = nil
    }
    
    // MARK: Handle results from analysis process
    func show(errorMessage message: String) {
        guard let document = self.visionDocument else {
            return
        }
        
        // Display an error with a custom message and custom action on the analysis screen
        analysisDelegate?.displayError(withMessage: errorMessage, andAction: {
            self.analyzeDocument(visionDocument: document, completion: self.didDocumentAnalysisFinished)
        })
    }
    
    func show(result: GINIResult, fromDocument document: GINIDocument) {
        let resultParameters = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        
        if hasExtactions {
            showResultsScreen()
        } else {
            showNoResultsScreen()
        }
    }
    
    fileprivate func showResultsScreen() {
        let customResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "resultScreen") as? ResultTableViewController)!
        customResultsScreen.result = documentService.result
        customResultsScreen.document = documentService.document
        
        DispatchQueue.main.async { [weak self] in
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
            self?.analysisDelegate = nil
        }
    }
    
    fileprivate func showNoResultsScreen() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self, let analysisDelegate = self.analysisDelegate else { return }
            let shown = analysisDelegate.tryDisplayNoResultsScreen()
            if !shown {
                let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
                customNoResultsScreen.delegate = self
                self.screenAPIViewController.setNavigationBarHidden(false, animated: false)
                self.screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
            }
            self.analysisDelegate = nil
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
        self.analyzeDocument(visionDocument: document, completion: self.didDocumentAnalysisFinished)
    }
    
    func didDetect(qrDocument: GiniQRCodeDocument) {
        self.analyzeDocument(visionDocument: qrDocument, completion: self.didDocumentAnalysisFinished)
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        // Analyze reviewed document when changes were made by the user during review or
        // there is no result and is not analysing.
        if changes || (!documentService.isAnalyzing && documentService.result == nil) {
            self.analyzeDocument(visionDocument: document, completion: self.didDocumentAnalysisFinished)

            return
        }
    }
    
    func didCancelCapturing() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    // Optional delegate methods
    func didCancelReview() {
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalsyis()
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
        self.analysisDelegate = analysisDelegate
        
        // if there is already results, present them
        if let result = documentService.result,
            let document = documentService.document {
            show(result: result, fromDocument: document)
        }
        
        // The analysis screen is where the user should be confronted with
        // any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let errorMessage = errorMessage {
            show(errorMessage: errorMessage)
        }
    }
    
    func didCancelAnalysis() {
        analysisDelegate = nil
        
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalsyis()
    }
    
}
