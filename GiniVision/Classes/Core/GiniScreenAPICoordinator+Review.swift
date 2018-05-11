//
//  GiniScreenAPICoordinator+Review.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Review Screen

extension GiniScreenAPICoordinator: ReviewViewControllerDelegate {
    
    func review(_ viewController: ReviewViewController, didReview document: GiniVisionDocument) {
        updateValue(for: document)
    }
    
    func createReviewScreen(withDocument document: GiniVisionDocument,
                            isFirstScreen: Bool = false) -> ReviewViewController {
        let reviewViewController = ReviewViewController(document: document,
                                                        giniConfiguration: giniConfiguration)
        reviewViewController.delegate = self
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
                         didRotate documentRequest: DocumentRequest) {
        updateValue(for: documentRequest.document)
    }
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didDelete documentRequest: DocumentRequest) {
        removeFromDocuments(document: documentRequest.document)
        visionDelegate?.didCancelReview(for: documentRequest.document)
        
        if documentRequests.isEmpty {
            closeMultipageScreen()
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didReorder documentRequests: [DocumentRequest]) {
        replaceDocuments(with: documentRequests)
    }
    
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        closeMultipageScreen()
    }

    func createMultipageReviewScreenContainer(with documentRequests: [DocumentRequest])
        -> MultipageReviewViewController {
            let vc = MultipageReviewViewController(documentRequests: documentRequests,
                                                   giniConfiguration: giniConfiguration)
            vc.delegate = self
            vc.setupNavigationItem(usingResources: backButtonResource,
                                   selector: #selector(closeMultipageScreen),
                                   position: .left,
                                   target: self)
            
            vc.setupNavigationItem(usingResources: nextButtonResource,
                                   selector: #selector(showAnalysisScreen),
                                   position: .right,
                                   target: self)
            
            vc.navigationItem.rightBarButtonItem?.isEnabled = false
            return vc
    }
    
    @objc fileprivate func closeMultipageScreen() {
        self.screenAPINavigationController.popViewController(animated: true)
    }
    
    func showMultipageReview() {
        if !screenAPINavigationController.viewControllers.contains(multiPageReviewViewController) {
            screenAPINavigationController.pushViewController(multiPageReviewViewController,
                                                             animated: true)
        }
    }
    
    func refreshMultipageReviewNextButton(with documentRequests: [DocumentRequest]) {
        multiPageReviewViewController.navigationItem
            .rightBarButtonItem?
            .isEnabled = documentRequests
                .reduce(true, { result, documentRequest in
                    result && documentRequest.isUploaded
                })
    }
}
