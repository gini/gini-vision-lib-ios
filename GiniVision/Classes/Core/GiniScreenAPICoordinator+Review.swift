//
//  GiniScreenAPICoordinator+Review.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Review Screen

internal extension GiniScreenAPICoordinator {
    func createReviewScreen(withDocument document: GiniVisionDocument,
                            isFirstScreen: Bool = false) -> ReviewViewController {
        let reviewViewController = ReviewViewController(document, successBlock: { [weak self] document in
            guard let `self` = self else { return }
            self.visionDocuments[0] = document
            self.changesOnReview = true
            }, failureBlock: { _ in
        })
        
        reviewViewController.title = giniConfiguration.navigationBarReviewTitle
        reviewViewController.view.backgroundColor = giniConfiguration.backgroundColor
        reviewViewController.setupNavigationItem(usingResources: nextButtonResource,
                                                 selector: #selector(showAnalysisScreen),
                                                 position: .right,
                                                 target: self)
        
        let backResource = isFirstScreen ? closeButtonResource : backButtonResource
        reviewViewController.setupNavigationItem(usingResources: backResource,
                                                 selector: #selector(back),
                                                 position: .left,
                                                 target: self)
        
        return reviewViewController
    }
}

// MARK: - Multipage Review screen

extension GiniScreenAPICoordinator: MultipageReviewViewControllerDelegate {
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didUpdateDocuments documents: [GiniImageDocument]) {
        self.visionDocuments = documents
        self.visionDocuments.forEach { document in
            self.visionDelegate?.didReview?(document: document,
                                            withChanges: true)
        }
        
        if self.visionDocuments.isEmpty {
            self.closeMultipageScreen()
        }
    }
    
    func createMultipageReviewScreenContainer(withImageDocuments documents: [GiniImageDocument])
        -> MultipageReviewViewController {
            let vc = MultipageReviewViewController(imageDocuments: documents, giniConfiguration: giniConfiguration)
            vc.delegate = self
            vc.setupNavigationItem(usingResources: backButtonResource,
                                   selector: #selector(closeMultipageScreen),
                                   position: .left,
                                   target: self)
            
            vc.setupNavigationItem(usingResources: nextButtonResource,
                                   selector: #selector(showAnalysisScreen),
                                   position: .right,
                                   target: self)
            return vc
    }
    
    @objc fileprivate func closeMultipageScreen() {
        self.screenAPINavigationController.popViewController(animated: true)
        self.multiPageReviewController = nil
    }
    
    func showMultipageReview(withImageDocuments imageDocuments: [GiniImageDocument]) {
        multiPageReviewController = createMultipageReviewScreenContainer(withImageDocuments: imageDocuments)
        screenAPINavigationController.pushViewController(multiPageReviewController!,
                                                         animated: true)
    }
}
