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
        updateDocument(for: document)
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
                         didRotate page: GiniVisionPage) {
        updateDocument(for: page.document)
    }
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didDelete page: GiniVisionPage) {
        removeFromDocuments(document: page.document)
        visionDelegate?.didCancelReview(for: page.document)
        
        if pages.isEmpty {
            closeMultipageScreen()
        }
    }
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didReorder pages: [GiniVisionPage]) {
        replaceDocuments(with: pages)
    }
    
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didTapRetryUploadFor page: GiniVisionPage) {
        update(page.document, withError: nil, isUploaded: false)
        visionDelegate?.didCapture(document: page.document, uploadDelegate: self)
    }
    
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        closeMultipageScreen()
    }

    func createMultipageReviewScreenContainer(with pages: [GiniVisionPage])
        -> MultipageReviewViewController {
            let vc = MultipageReviewViewController(pages: pages,
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
    
    func refreshMultipageReviewNextButton(with pages: [GiniVisionPage]) {
        multiPageReviewViewController.navigationItem
            .rightBarButtonItem?
            .isEnabled = pages
                .reduce(true, { result, page in
                    result && page.isUploaded
                })
    }
}
