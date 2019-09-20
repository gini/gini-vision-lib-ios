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
    
    let client: GiniClient
    let documentMetadata: GINIDocumentMetadata?
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocuments: [GiniVisionDocument]?
    var visionConfiguration: GiniConfiguration
    var sendFeedbackBlock: (([String: GINIExtraction]) -> Void)?
    
    init(configuration: GiniConfiguration,
         importedDocuments documents: [GiniVisionDocument]?,
         client: GiniClient,
         documentMetadata: GINIDocumentMetadata?) {
        self.visionConfiguration = configuration
        self.visionDocuments = documents
        self.client = client
        self.documentMetadata = documentMetadata
        super.init()
    }
    
    func start() {
        let gymApiBaseUrl = "https://gym.gini.net/"
        let sessionManager = GVLGoogleAuthSessionManager(withGymApiBaseUrl: gymApiBaseUrl)
        sessionManager.email = "mobile.gini@gmail.com"
        sessionManager.idToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjBiMGJmMTg2NzQzNDcxYTFlZGNhYzMwNjBkMTI1NmY5ZTQwNTBiYTgiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIxMDMzNzU3NDczNjc5LXJjZmV1bmppaWgxcmM1bm9kN2ExODY3cm91cm43cDBlLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiMTAzMzc1NzQ3MzY3OS1lbDlkZDNkZjI5cDhxNmxrNTJsbDY0czM0MDZvOWF2YS5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsInN1YiI6IjExNTY4NzAwMjIyNDI3MjU2NDY4MyIsImVtYWlsIjoibW9iaWxlLmdpbmlAZ21haWwuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJNb2JpbGUgR2luaSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vLWxTR0hzOFk2WmowL0FBQUFBQUFBQUFJL0FBQUFBQUFBQUFBL0FDSGkzcmMzUnRZUktzOXNKOXZiM1Vwakc2WWVyNkRTcUEvczk2LWMvcGhvdG8uanBnIiwiZ2l2ZW5fbmFtZSI6Ik1vYmlsZSIsImZhbWlseV9uYW1lIjoiR2luaSIsImxvY2FsZSI6ImVuIiwiaWF0IjoxNTY4OTkwMTI1LCJleHAiOjE1Njg5OTM3MjV9.qg4VpoH0q_fkcIq4Q2qlrwoE6oeJd3NtGIBtwHa0vbsxScmDo4pGALwD1nqCtze45Lq-CXuSKURQxwjpZ-G66pREsC-f9csY1h2NJ_ETSrnfck4dCSSpaEt9VhTCZo3iI8EMjcm8ZyEQn7M1sXGdvLZIYcvhu8IgvpO5Af8f1HVgQ_cnOUxwfysHUIa-qp8CCSCZ72QVrcFkD-4is33GzWTjqt3gIIafQj-ubMMczv2GVCjoED-fmIWmEn9dy10M36BrXkuwtU96VnJGQo5VYyD_sQF5B9vB-E8b6Pf8Xhw3F0T_lpYyTZpgwQpAE7mncKI6T9gPHWn436xUUY9Q9Q"
        
        let viewController = GiniVision.viewController(withSessionManager: sessionManager,
                                                       baseUrl: gymApiBaseUrl,
                                                       importedDocuments: visionDocuments,
                                                       configuration: visionConfiguration,
                                                       resultsDelegate: self,
                                                       documentMetadata: documentMetadata)
                       
        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.navigationBar.barTintColor = visionConfiguration.navigationBarTintColor
        screenAPIViewController.navigationBar.tintColor = visionConfiguration.navigationBarTitleColor
        screenAPIViewController.setNavigationBarHidden(true, animated: false)
        screenAPIViewController.delegate = self
        screenAPIViewController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    fileprivate func showResultsScreen(results: [String: GINIExtraction]) {
        let customResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "resultScreen") as? ResultTableViewController)!
        customResultsScreen.result = results
        
        DispatchQueue.main.async { [weak self] in
            self?.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self?.screenAPIViewController.pushViewController(customResultsScreen, animated: true)
        }
    }
    
}

// MARK: - UINavigationControllerDelegate

extension ScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // Since the NoResultViewController and ResultTableViewController are in the navigation stack,
        // when it is necessary to go back, it dismiss the ScreenAPI so the Analysis screen is not shown again
        
        if fromVC is NoResultViewController {
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
        }
        
        if let fromVC = fromVC as? ResultTableViewController {
            self.sendFeedbackBlock?(fromVC.result)
            self.delegate?.screenAPI(coordinator: self, didFinish: ())
        }
        
        return nil
    }
}

// MARK: - NoResultsScreenDelegate

extension ScreenAPICoordinator: NoResultsScreenDelegate {
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        screenAPIViewController.popToRootViewController(animated: true)
    }
}

// MARK: - GiniVisionResultsDelegate

extension ScreenAPICoordinator: GiniVisionResultsDelegate {
    func giniVisionAnalysisDidFinishWith(result: AnalysisResult,
                                         sendFeedbackBlock: @escaping ([String: Extraction]) -> Void) {
        showResultsScreen(results: result.extractions)
        self.sendFeedbackBlock = sendFeedbackBlock
    }
    
    func giniVisionDidCancelAnalysis() {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    func giniVisionAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool) {
        if !showingNoResultsScreen {
            let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
            customNoResultsScreen.delegate = self
            self.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self.screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
        }
    }
}
