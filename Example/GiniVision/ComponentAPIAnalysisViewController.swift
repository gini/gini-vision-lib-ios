//
//  ComponentAPIAnalysisViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 15/07/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

/**
 View controller showing how to implement the analysis screen using the Component API of the Gini Vision Library for iOS and
 how to process the previously reviewed image using the Gini SDK for iOS
 */
class ComponentAPIAnalysisViewController: UIViewController {
    
    /**
     The image data of the captured document to be reviewed.
     */
    var document: GiniVisionDocument?
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    @IBOutlet var errorButton: UIButton!
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorButton.alpha = 0.0
        
        /***************************************************************************
         * ANALYSIS SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         ***************************************************************************/
        
        // (1. If not already done: Create and set a custom configuration object)
        // See `ComponentAPICameraViewController.swift` for implementation details.
        
        // 2. Create the analysis view controller
        guard let document = document else { return }
        
        // In case that the view is loaded but is not analysing (i.e: user imported a PDF with the Open With feature), it should start.
        if !AnalysisManager.sharedManager.isAnalyzing {
            AnalysisManager.sharedManager.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: nil)
        }
        
        contentController = AnalysisViewController(document)
        
        // 3. Display the analysis view controller
        displayContent(contentController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navController = navigationController else { return }
        if isFirstViewController(inNavController: navController) {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Abbrechen", style: .plain, target: self, action: #selector(closeAction))
        }
    }
    
    func closeAction() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Subscribe to analysis events which will be fired when the analysis process ends.
        // Either with a valid result or an error.
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnalysis(errorNotification:)), name: NSNotification.Name(rawValue: GINIAnalysisManagerDidReceiveErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAnalysis(resultNotification:)), name: NSNotification.Name(rawValue: GINIAnalysisManagerDidReceiveResultNotification), object: nil)
        
        // Because results may come in during view controller transition,
        // check for already existent results in shared analysis manager.
        handleExistinResults()
        
        // Start loading animation.
        (contentController as? AnalysisViewController)?.showAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Never forget to remove observers when you support iOS versions prior to 9.0.
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        // Cancel analysis process to avoid unnecessary network calls.
        if parent == nil {
            AnalysisManager.sharedManager.cancelAnalysis()
        }
    }
    
    // Displays the content controller inside the container view
    func displayContent(_ controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    // MARK: User actions
    @IBAction func errorButtonTapped(_ sender: AnyObject) {
        (contentController as? AnalysisViewController)?.showAnimation()
        hideErrorButton()
        
        // Retry analysis of the document.
        guard let document = document else { return }
        AnalysisManager.sharedManager.analyzeDocument(withData: document.data, cancelationToken: CancelationToken(), completion: nil)
    }
    
    // MARK: Handle results from analysis process
    func handleExistinResults() {
        if let result = AnalysisManager.sharedManager.result,
           let document = AnalysisManager.sharedManager.document {
            handleAnalysis(result, fromDocument: document)
        } else if let error = AnalysisManager.sharedManager.error {
            handleAnalysis(error)
        }
    }
    
    func handleAnalysis(errorNotification notification: Notification) {
        let error = notification.userInfo?[GINIAnalysisManagerErrorUserInfoKey] as? NSError
        handleAnalysis(error)
    }
    
    func handleAnalysis(resultNotification notification: Notification) {
        if let result = notification.userInfo?[GINIAnalysisManagerResultDictionaryUserInfoKey] as? GINIResult,
           let document = notification.userInfo?[GINIAnalysisManagerDocumentUserInfoKey] as? GINIDocument {
            handleAnalysis(result, fromDocument: document)
        } else {
            handleAnalysis(nil)
        }
    }
    
    func handleAnalysis(_ error: Error?) {
        if let error = error {
            print(error)
        }
        
        // For the sake of simplicity we'll always present a generic error which allows the user to retry the analysis.
        // In a real world application different messages depending on the kind of error might be appropriate.
        DispatchQueue.main.async { 
            self.displayError()
        }
    }
    
    func handleAnalysis(_ result: GINIResult, fromDocument document: GINIDocument) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = result.filter { payFive.contains($0.0) }.count > 0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if hasPayFive {
            let vc = storyboard.instantiateViewController(withIdentifier: "resultScreen") as! ResultTableViewController
            vc.result = result
            vc.document = document
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Remove analysis screen from navigation stack.
        if var navigationStack = navigationController?.viewControllers,
           let index = navigationStack.index(of: self) {
            navigationStack.remove(at: index)
            navigationController?.viewControllers = navigationStack
            if navigationStack.count == 1 {
                if let resultsScreen = navigationStack.first as? ResultTableViewController {
                    resultsScreen.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schließen", style: .plain, target: resultsScreen, action: #selector(resultsScreen.closeAction))
                }
            }
        }
    }
    
    // MARK: Error button handling
    func displayError() {
        (contentController as? AnalysisViewController)?.hideAnimation()
        showErrorButton()
    }
    
    func showErrorButton() {
        guard errorButton.alpha != 1.0 else {
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.errorButton.alpha = 1.0
        }
    }
    
    func hideErrorButton() {
        guard errorButton.alpha != 0.0 else {
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.errorButton.alpha = 0.0
        }
    }

}

