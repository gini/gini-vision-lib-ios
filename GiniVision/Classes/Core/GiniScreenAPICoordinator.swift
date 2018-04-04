//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    var rootViewController: UIViewController { get }
}

typealias ValidatedDocument = (document: GiniVisionDocument, error: Error?)

internal final class GiniScreenAPICoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return screenAPINavigationController
    }
    
    fileprivate(set) lazy var screenAPINavigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.delegate = self
        navigationController.applyStyle(withConfiguration: self.giniConfiguration)
        return navigationController
    }()
    
    // Screens
    var analysisViewController: AnalysisViewController?
    var cameraViewController: CameraViewController?
    var imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController?
    var reviewViewController: ReviewViewController?
    var multiPageReviewController: MultipageReviewViewController?
    lazy var documentPickerCoordinator: DocumentPickerCoordinator = {
        return DocumentPickerCoordinator()
    }()
    
    // Properties
    fileprivate(set) var giniConfiguration: GiniConfiguration
    fileprivate let multiPageTransition = MultipageReviewTransitionAnimator()
    var changesOnReview: Bool = false
    var visionDocuments: [GiniVisionDocument] = []
    weak var visionDelegate: GiniVisionDelegate?
    
    // Resources
    fileprivate(set) lazy var backButtonResource =
        PreferredButtonResource(image: "navigationReviewBack",
                                title: "ginivision.navigationbar.review.back",
                                comment: "Button title in the navigation bar for the back button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleBackButton)
    fileprivate(set) lazy var cancelButtonResource =
        PreferredButtonResource(image: "navigationAnalysisBack",
                                title: "ginivision.navigationbar.analysis.back",
                                comment: "Button title in the navigation bar for" +
            "the back button on the analysis screen",
                                configEntry: self.giniConfiguration.navigationBarAnalysisTitleBackButton)
    fileprivate(set) lazy var closeButtonResource =
        PreferredButtonResource(image: "navigationCameraClose",
                                title: "ginivision.navigationbar.camera.close",
                                comment: "Button title in the navigation bar for the close button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate(set) lazy var helpButtonResource =
        PreferredButtonResource(image: "navigationCameraHelp",
                                title: "ginivision.navigationbar.camera.help",
                                comment: "Button title in the navigation bar for the help button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleHelpButton)
    fileprivate(set) lazy var nextButtonResource =
        PreferredButtonResource(image: "navigationReviewContinue",
                                title: "ginivision.navigationbar.review.continue",
                                comment: "Button title in the navigation bar for " +
            "the continue button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleContinueButton)
    
    init(withDelegate delegate: GiniVisionDelegate?,
         giniConfiguration: GiniConfiguration) {
        self.visionDelegate = delegate
        self.giniConfiguration = giniConfiguration
        super.init()
    }
    
    func start(withDocuments documents: [GiniVisionDocument]?) -> UIViewController {
        let viewControllers: [UIViewController]
        if let documents = documents, !documents.isEmpty {
            if documents.count > 1, !giniConfiguration.multipageEnabled {
                fatalError("You are trying to import several files from other app when the Multipage feature is not " +
                    "enabled. To enable it just set `multipageEnabled` to `true` in the `GiniConfiguration`")
            }
            
            if !documents.containsDifferentTypes {
                self.visionDocuments = documents
                if !giniConfiguration.openWithEnabled {
                    fatalError("You are trying to import a file from other app when the Open With feature is not " +
                        "enabled. To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
                }
                viewControllers = initialViewControllers(withDocuments: documents)
                
            } else {
                fatalError("You are trying to import both PDF and images at the same time. " +
                    "For now it is only possible to import either images or one PDF")
            }
        } else {
            self.cameraViewController = self.createCameraViewController()
            viewControllers = [self.cameraViewController!]
        }
        
        self.screenAPINavigationController.setViewControllers(viewControllers, animated: false)
        return ContainerNavigationController(rootViewController: self.screenAPINavigationController,
                                             parent: self)
    }
    
    private func initialViewControllers(withDocuments documents: [GiniVisionDocument]) -> [UIViewController] {
        if let imageDocuments = documents as? [GiniImageDocument] {
            if giniConfiguration.multipageEnabled {
                self.cameraViewController = self.createCameraViewController()
                self.cameraViewController?.updateMultipageReviewButton(withImage: imageDocuments[0].previewImage,
                                                                       showingStack: imageDocuments.count > 1)
                self.multiPageReviewController =
                    createMultipageReviewScreenContainer(withImageDocuments: imageDocuments)
                
                return [self.cameraViewController!, self.multiPageReviewController!]
            } else {
                self.cameraViewController = self.createCameraViewController()
                self.reviewViewController = self.createReviewScreen(withDocument: documents[0])
                return [self.cameraViewController!, self.reviewViewController!]
            }
        } else {
            self.analysisViewController = self.createAnalysisScreen(withDocument: documents[0])
            return [self.analysisViewController!]
        }
    }
}

// MARK: - Button actions

extension GiniScreenAPICoordinator {
    
    @objc func back() {
        if self.screenAPINavigationController.viewControllers.count == 1 {
            self.closeScreenApi()
        } else {
            self.screenAPINavigationController.popViewController(animated: true)
        }
    }
    
    @objc func closeScreenApi() {
        self.visionDelegate?.didCancelCapturing()
    }
    
    @objc func showHelpMenuScreen() {
        self.screenAPINavigationController.pushViewController(HelpMenuViewController(), animated: true)
    }
    
    @objc func showAnalysisScreen() {
        let documentToShow = visionDocuments[0]
        if let didReview = visionDelegate?.didReview(document:withChanges:) {
            didReview(documentToShow, changesOnReview)
        } else if let didReview = visionDelegate?.didReview(_:withChanges:) {
            didReview(documentToShow.data, changesOnReview)
        } else {
            fatalError("GiniVisionDelegate.didReview(document: GiniVisionDocument," +
                "withChanges changes: Bool) should be implemented")
        }
        
        self.analysisViewController = createAnalysisScreen(withDocument: documentToShow)
        self.screenAPINavigationController.pushViewController(analysisViewController!, animated: true)
    }
    
    @objc func backToCamera() {
        if let cameraViewController = cameraViewController {
            screenAPINavigationController.popToViewController(cameraViewController, animated: true)
        }
    }
}

// MARK: - Navigation delegate

extension GiniScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC == analysisViewController && operation == .pop {
            analysisViewController = nil
            visionDelegate?.didCancelAnalysis?()
        }
        if fromVC == reviewViewController && toVC == cameraViewController {
            reviewViewController = nil
            visionDelegate?.didCancelReview?()
            visionDocuments.removeAll()
        }
        
        let isFromCameraToMultipage = (toVC == multiPageReviewController && fromVC == cameraViewController)
        let isFromMultipageToCamera = (fromVC == multiPageReviewController && toVC == cameraViewController)
        
        if isFromCameraToMultipage || isFromMultipageToCamera {
            return multipageTransition(operation: operation, from: fromVC, to: toVC)
        }
        
        return nil
    }
    
    private func multipageTransition(operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let reviewImagesButtonCenter = cameraViewController?.multipageReviewButton,
            let buttonFrame = cameraViewController?
                .multipageReviewContentView
                .convert(reviewImagesButtonCenter.frame,
                         to: self.screenAPINavigationController.view) else {
                            return nil
        }
        
        multiPageTransition.originFrame = buttonFrame
        multiPageTransition.operation = operation
        
        if let multipageVC = fromVC as? MultipageReviewViewController, let cameraVC = toVC as? CameraViewController {
            let visibleImageAndSize = multipageVC.visibleImage(in: multipageVC.mainCollection)
            multiPageTransition.popImage = visibleImageAndSize.image
            multiPageTransition.popImageFrame = visibleImageAndSize.size
            
            var image: UIImage? = nil
            if let visibleIndex = multipageVC.visibleCell(in: multipageVC.mainCollection)?.row {
                image = self.visionDocuments[visibleIndex].previewImage
            }
            cameraVC.updateMultipageReviewButton(withImage: image,
                                                 showingStack: self.visionDocuments.count > 1)
            
            if visionDocuments.isEmpty {
                return nil
            }
        }
        
        return multiPageTransition
    }
}
