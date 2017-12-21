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
    var analysisDelegate: AnalysisDelegate?
    var visionDocument: GiniVisionDocument?
    var visionConfiguration: GiniConfiguration
    var result: GINIResult? {
        didSet {
            if let result = result,
                let document = document,
                analysisDelegate != nil {
                present(result, fromDocument: document)
            }
        }
    }
    var document: GINIDocument?
    var errorMessage: String? {
        didSet {
            if let errorMessage = errorMessage {
                DispatchQueue.main.async {[weak self] in
                    guard let `self` = self else { return }
                    self.show(errorMessage: errorMessage)
                }
            }
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
    func analyzeDocument(visionDocument document: GiniVisionDocument) {
        cancelAnalsyis()
        visionDocument = document
        
        documentService.analyzeDocument(withData: document.data,
                                        cancelationToken: CancelationToken(),
                                        completion: { (result, document, error) in
                                            if error != nil {
                                                self.errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
                                                return
                                            }
                                            
                                            if let result = result,
                                                let document = document {
                                                self.document = document
                                                self.result = result
                                            }
        })
    }
    
    func cancelAnalsyis() {
        documentService.cancelAnalysis()
        result = nil
        document = nil
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
            self.analyzeDocument(visionDocument: document)
        })
    }
    
    func present(_ result: GINIResult, fromDocument document: GINIDocument) {
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
        customResultsScreen.result = result
        customResultsScreen.document = document
        
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
            if let document = document {
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
        analyzeDocument(visionDocument: document)
    }
    
    func didDetect(qrDocument: GiniQRCodeDocument) {
        result = qrDocument.extractedParameters.reduce(into: [String: GINIExtraction]()) { (result, parameter) in
            result[parameter.key] = GINIExtraction(name: parameter.key,
                                                   value: parameter.value,
                                                   entity: parameter.value,
                                                   box: [:])
        }
        showResultsScreen()
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        // Analyze reviewed document when changes were made by the user during review or
        // there is no result and is not analysing.
        if changes || (!documentService.isAnalyzing && result == nil) {
            analyzeDocument(visionDocument: document)
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
        if let result = result,
            let document = document {
            present(result, fromDocument: document)
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
