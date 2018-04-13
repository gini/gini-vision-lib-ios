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
            self.updateValueInSessionDocuments(for: document)
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
    
    func multipageReview(_ controller: MultipageReviewViewController, didRotate document: GiniImageDocument) {
        updateValueInSessionDocuments(for: document)
        visionDelegate?.didReview?(document: document,
                                   withChanges: true)
    }
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didDelete document: GiniImageDocument) {
        removeFromDocuments(document: document)
        visionDelegate?.didCancelReview(for: document)
        
        if sessionDocuments.isEmpty {
            closeMultipageScreen()
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didReorder documents: [ValidatedDocument]) {
        replaceSessionDocuments(with: documents)
    }

    func createMultipageReviewScreenContainer(with validatedDocuments: [ValidatedDocument])
        -> MultipageReviewViewController {
            let vc = MultipageReviewViewController(validatedDocuments: validatedDocuments,
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
    
    func refreshMultipageReview(with imageDocuments: [ValidatedDocument]) {
        multiPageReviewViewController.validatedDocuments = imageDocuments
        multiPageReviewViewController.reloadCollections()
    }
}
