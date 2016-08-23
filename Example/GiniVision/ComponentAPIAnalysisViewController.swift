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
    var imageData: NSData!
    
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
        contentController = GINIAnalysisViewController(imageData)
        
        // 3. Display the analysis view controller
        displayContent(contentController)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Subscribe to analysis events which will be fired when the analysis process ends.
        // Either with a valid result or an error.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleAnalysis(errorNotification:)), name: GINIAnalysisManagerDidReceiveErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleAnalysis(resultNotification:)), name: GINIAnalysisManagerDidReceiveResultNotification, object: nil)
        
        // Because results may come in during view controller transition,
        // check for already existent results in shared analysis manager.
        handleExistinResults()
        
        // Start loading animation.
        (contentController as? GINIAnalysisViewController)?.showAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Never forget to remove observers when you support iOS versions prior to 9.0.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        
        // Cancel analysis process to avoid unnecessary network calls.
        if parent == nil {
            AnalysisManager.sharedManager.cancelAnalysis()
        }
    }
    
    // Displays the content controller inside the container view
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
    // MARK: User actions
    @IBAction func errorButtonTapped(sender: AnyObject) {
        (contentController as? GINIAnalysisViewController)?.showAnimation()
        hideErrorButton()
        
        // Retry analysis of the document.
        AnalysisManager.sharedManager.analyzeDocument(withImageData: imageData, cancelationToken: CancelationToken(), completion: nil)
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
    
    func handleAnalysis(errorNotification notification: NSNotification) {
        let error = notification.userInfo?[GINIAnalysisManagerErrorUserInfoKey] as? NSError
        handleAnalysis(error)
    }
    
    func handleAnalysis(resultNotification notification: NSNotification) {
        if let result = notification.userInfo?[GINIAnalysisManagerResultDictionaryUserInfoKey] as? GINIResult,
           let document = notification.userInfo?[GINIAnalysisManagerDocumentUserInfoKey] as? GINIDocument {
            handleAnalysis(result, fromDocument: document)
        } else {
            handleAnalysis(nil)
        }
    }
    
    func handleAnalysis(error: NSError?) {
        if let error = error {
            print(error.description)
        }
        
        // For the sake of simplicity we'll always present a generic error which allows the user to retry the analysis.
        // In a real world application different messages depending on the kind of error might be appropriate.
        dispatch_async(dispatch_get_main_queue()) { 
            self.displayError()
        }
    }
    
    func handleAnalysis(result: GINIResult, fromDocument document: GINIDocument) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = result.filter { payFive.contains($0.0) }.count > 0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if hasPayFive {
            let vc = storyboard.instantiateViewControllerWithIdentifier("resultScreen") as! ResultTableViewController
            vc.result = result
            vc.document = document
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard.instantiateViewControllerWithIdentifier("noResultScreen") as! NoResultViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        // Remove analysis screen from navigation stack.
        if var navigationStack = navigationController?.viewControllers,
           let index = navigationStack.indexOf(self) {
            navigationStack.removeAtIndex(index)
            navigationController?.viewControllers = navigationStack
        }
    }
    
    // MARK: Error button handling
    func displayError() {
        (contentController as? GINIAnalysisViewController)?.hideAnimation()
        showErrorButton()
    }
    
    func showErrorButton() {
        guard errorButton.alpha != 1.0 else {
            return
        }
        UIView.animateWithDuration(0.5) {
            self.errorButton.alpha = 1.0
        }
    }
    
    func hideErrorButton() {
        guard errorButton.alpha != 0.0 else {
            return
        }
        UIView.animateWithDuration(0.5) { 
            self.errorButton.alpha = 0.0
        }
    }

}

