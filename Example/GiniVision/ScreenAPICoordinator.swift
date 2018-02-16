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
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocument: GiniVisionDocument?
    var visionConfiguration: GiniConfiguration
    var sendFeedbackBlock: (([String : GINIExtraction]) -> ())?
    
    init(configuration: GiniConfiguration,
         importedDocument document: GiniVisionDocument?,
         client: GiniClient) {
        self.visionConfiguration = configuration
        self.visionDocument = document
        self.client = client
        super.init()
    }
    
    func start() {
        let viewController = GiniVision.viewController(withClient: client,
                                                       importedDocument: visionDocument,
                                                       giniConfiguration: visionConfiguration,
                                                       resultsDelegate: self)
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
                              animationControllerFor operation: UINavigationControllerOperation,
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
    func giniVision(_ documents: [GiniVisionDocument],
                    analysisDidFinishWithResults results: [String : GINIExtraction],
                    sendFeedback: @escaping ([String : GINIExtraction]) -> Void) {
        showResultsScreen(results: results)
        sendFeedbackBlock = sendFeedback
    }
    
    func giniVision(_ documents: [GiniVisionDocument], analysisDidCancel: Bool) {
        delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    func giniVision(_ documents: [GiniVisionDocument], analysisDidFinishWithNoResults showedNoResultsScreen: Bool) {
        if !showedNoResultsScreen {
            let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
            customNoResultsScreen.delegate = self
            self.screenAPIViewController.setNavigationBarHidden(false, animated: false)
            self.screenAPIViewController.pushViewController(customNoResultsScreen, animated: true)
        }
    }
}
