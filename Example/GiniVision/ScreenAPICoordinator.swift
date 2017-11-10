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
                show(errorMessage: errorMessage)
            }
        }
    }
    
    init(configuration: GiniConfiguration, importedDocument document: GiniVisionDocument?, documentService: DocumentService) {
        self.visionConfiguration = configuration
        self.visionDocument = document
        self.documentService = documentService
    }
    
    func start() {
        screenAPIViewController = GiniVision.viewController(withDelegate: self, withConfiguration: visionConfiguration, importedDocument: visionDocument) as! UINavigationController
        screenAPIViewController.delegate = self
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(visionDocument document: GiniVisionDocument) {
        cancelAnalsyis()
        visionDocument = document
        
        print("Analysing document with size \(Double(document.data.count) / 1024.0)")
        documentService.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: { inner in
            do {
                guard let response = try inner?(),
                    let result = response.0,
                    let document = response.1 else {
                        return self.errorMessage = "Ein unbekannter Fehler ist aufgetreten. Wiederholen"
                }
                self.document = document
                self.result = result
            } catch _ {
                self.errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
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
        let customResultsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resultScreen") as! ResultTableViewController
        customResultsScreen.result = result
        customResultsScreen.document = document
        documentService.sendFeedback(forDocument: document!)
        DispatchQueue.main.async { [weak self] in
            print("Presenting results screen...")
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
            self?.analysisDelegate = nil
        }
    }
    
    fileprivate func showNoResultsScreen() {
        DispatchQueue.main.async { [weak self] in
            print("Presenting no results screen...")
            guard let `self` = self, let analysisDelegate = self.analysisDelegate else { return }
            let shown = analysisDelegate.tryDisplayNoResultsScreen()
            if !shown {
                let customNoResultsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
                customNoResultsScreen.delegate = self
                self.screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
            }
            self.analysisDelegate = nil
        }
    }
    
}

// MARK: UINavigationControllerDelegate

extension ScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let fromVC = navigationController.transitionCoordinator?.viewController(forKey: .from)
        if fromVC is NoResultViewController || fromVC is ResultTableViewController {
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
        }
    }
}

// MARK: NoResultsScreenDelegate

extension ScreenAPICoordinator: NoResultsScreenDelegate {
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        self.screenAPIViewController.popToRootViewController(animated: true)
    }
}


// MARK: GiniVisionDelegate

extension ScreenAPICoordinator: GiniVisionDelegate {
    
    func didCapture(document: GiniVisionDocument) {
        print("Screen API received image data")
        
        // Analyze document data right away with the Gini SDK for iOS to have results in as early as possible.
        analyzeDocument(visionDocument: document)
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        print("Screen API received updated image data with \(changes ? "changes" : "no changes")")
        
        // Analyze reviewed document when changes were made by the user during review or there is no result and is not analysing.
        if changes || (!documentService.isAnalyzing && result == nil) {
            analyzeDocument(visionDocument: document)
            return
        }
    }
    
    func didCancelCapturing() {
        print("Screen API canceled capturing")
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    // Optional delegate methods
    func didCancelReview() {
        print("Screen API canceled review")
        
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalsyis()
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
        print("Screen API started analysis screen")
        self.analysisDelegate = analysisDelegate
        
        // if there is already results, present them
        if let result = result,
            let document = document {
            present(result, fromDocument: document)
        }
        
        // The analysis screen is where the user should be confronted with any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let errorMessage = errorMessage {
            show(errorMessage: errorMessage)
        }
    }
    
    func didCancelAnalysis() {
        print("Screen API canceled analysis")
        
        analysisDelegate = nil
        
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalsyis()
    }
    
    
}
