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

final class GiniScreenAPICoordinator: NSObject, Coordinator {
    
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
    lazy var multiPageReviewViewController: MultipageReviewViewController = {
        if let type = self.sessionDocuments.type, type != .image {
            assertionFailure("The MultipageReviewViewController can only handle image documents.")
        }
        let multiPageReviewViewController =
            self.createMultipageReviewScreenContainer(with: self.sessionDocuments)
        return multiPageReviewViewController
    }()
    lazy var documentPickerCoordinator: DocumentPickerCoordinator = {
        return DocumentPickerCoordinator()
    }()
    
    // Properties
    fileprivate(set) var giniConfiguration: GiniConfiguration
    fileprivate(set) var sessionDocuments: [ValidatedDocument] = []
    fileprivate let multiPageTransition = MultipageReviewTransitionAnimator()
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
                let validatedDocuments: [ValidatedDocument] = documents.map { ValidatedDocument(value: $0) }
                self.addToDocuments(newDocuments: validatedDocuments)
                if !giniConfiguration.openWithEnabled {
                    fatalError("You are trying to import a file from other app when the Open With feature is not " +
                        "enabled. To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
                }
                viewControllers = initialViewControllers(withDocuments: validatedDocuments)
                
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
    
    private func initialViewControllers(withDocuments documents: [ValidatedDocument]) -> [UIViewController] {
        if documents.type == .image {
            if giniConfiguration.multipageEnabled {
                self.cameraViewController = self.createCameraViewController()
                self.cameraViewController?.updateMultipageReviewButton(withImage: documents[0].value.previewImage,
                                                                       showingStack: documents.count > 1)
                self.multiPageReviewViewController =
                    createMultipageReviewScreenContainer(with: documents)
                
                return [self.cameraViewController!, self.multiPageReviewViewController]
            } else {
                self.cameraViewController = self.createCameraViewController()
                self.reviewViewController = self.createReviewScreen(withDocument: documents[0].value)
                return [self.cameraViewController!, self.reviewViewController!]
            }
        } else {
            self.analysisViewController = self.createAnalysisScreen(withDocument: documents[0].value)
            return [self.analysisViewController!]
        }
    }
}

// MARK: - Session documents

extension GiniScreenAPICoordinator {
    func addToDocuments(newDocuments: [ValidatedDocument]) {
        sessionDocuments.append(contentsOf: newDocuments)
        
        if giniConfiguration.multipageEnabled {
            refreshMultipageReview(with: sessionDocuments)
        }
    }
    
    func removeFromDocuments(document: GiniVisionDocument) {
        sessionDocuments.remove(document)
    }
    
    func updateValueInDocuments(for document: GiniVisionDocument) {
        if let index = sessionDocuments.index(of: document) {
            sessionDocuments[index].value = document
        }
    }
    
    func updateUploadStatusInDocuments(for document: GiniVisionDocument, to uploaded: Bool) {
        if let index = sessionDocuments.index(of: document) {
            sessionDocuments[index].isUploaded = uploaded
        }
    }
    
    func updateErrorInDocuments(for document: GiniVisionDocument, to error: Error) {
        if let index = sessionDocuments.index(of: document) {
            sessionDocuments[index].error = error
        }
    }
    
    func replaceDocuments(with documents: [ValidatedDocument]) {
        sessionDocuments = documents
    }
    
    func clearDocuments() {
        sessionDocuments.removeAll()
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
        visionDelegate?.didReview(documents: sessionDocuments.map { $0.value })
        
        self.analysisViewController = createAnalysisScreen(withDocument: sessionDocuments[0].value)
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
            visionDelegate?.didCancelAnalysis()
        }
        if fromVC == reviewViewController && toVC == cameraViewController {
            // This can only happen when not using multipage
            reviewViewController = nil
            if let firstDocument = sessionDocuments.first?.value {
                if let didCancelReviewForDocument = visionDelegate?.didCancelReview(for:) {
                    didCancelReviewForDocument(firstDocument)
                } else {
                    fatalError("GiniVisionDelegate.didCancelReview(for document: GiniVisionDocument)" +
                        "should be implemented")
                }
                
                clearDocuments()
            }
        }
        
        let isFromCameraToMultipage = (toVC == multiPageReviewViewController && fromVC == cameraViewController)
        let isFromMultipageToCamera = (fromVC == multiPageReviewViewController && toVC == cameraViewController)
        
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
                image = self.sessionDocuments[visibleIndex].value.previewImage
            }
            cameraVC.updateMultipageReviewButton(withImage: image,
                                                 showingStack: self.sessionDocuments.count > 1)
            
            if sessionDocuments.isEmpty {
                return nil
            }
        }
        
        return multiPageTransition
    }
}
