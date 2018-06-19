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
        return self.createMultipageReviewScreenContainer(with: [])
    }()
    lazy var documentPickerCoordinator: DocumentPickerCoordinator = {
        return DocumentPickerCoordinator(giniConfiguration: giniConfiguration)
    }()
    
    // Properties
    fileprivate(set) var giniConfiguration: GiniConfiguration
    fileprivate(set) var pages: [GiniVisionPage] = []
    fileprivate let multiPageTransition = MultipageReviewTransitionAnimator()
    weak var visionDelegate: GiniVisionDelegate?
    
    // When there was an error uploading a document or analyzing it and the analysis screen
    // had not been initialized yet, both the error message and action has to be saved to show in the analysis screen.
    var analysisErrorAndAction: (message: String, action: () -> Void)?
    
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
                let pages: [GiniVisionPage] = documents.map { GiniVisionPage(document: $0) }
                self.addToDocuments(new: pages)
                if !giniConfiguration.openWithEnabled {
                    fatalError("You are trying to import a file from other app when the Open With feature is not " +
                        "enabled. To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
                }
                
                pages.forEach { visionDelegate?.didCapture(document: $0.document, networkDelegate: self) }
                viewControllers = initialViewControllers(with: pages)
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
    
    private func initialViewControllers(with pages: [GiniVisionPage]) -> [UIViewController] {
        if pages.type == .image {
            if giniConfiguration.multipageEnabled {
                self.cameraViewController = self.createCameraViewController()
                self.cameraViewController?
                    .replaceCapturedStackImages(with: pages.compactMap { $0.document.previewImage } )
                
                self.multiPageReviewViewController =
                    createMultipageReviewScreenContainer(with: pages)
                
                return [self.cameraViewController!, self.multiPageReviewViewController]
            } else {
                self.cameraViewController = self.createCameraViewController()
                self.reviewViewController = self.createReviewScreen(withDocument: pages[0].document)
                return [self.cameraViewController!, self.reviewViewController!]
            }
        } else {
            self.analysisViewController = createAnalysisScreen(withDocument: pages[0].document)
            return [self.analysisViewController!]
        }
    }
}

// MARK: - Session documents

extension GiniScreenAPICoordinator {
    func addToDocuments(new pages: [GiniVisionPage]) {
        self.pages.append(contentsOf: pages)
        
        if giniConfiguration.multipageEnabled, pages.type == .image {
            refreshMultipageReviewNextButton(with: self.pages)
            multiPageReviewViewController.updateCollections(with: self.pages)
        }
    }
    
    func removeFromDocuments(document: GiniVisionDocument) {
        pages.remove(document)
        
        if giniConfiguration.multipageEnabled, pages.type == .image {
            refreshMultipageReviewNextButton(with: pages)
        }
    }
    
    func updateDocument(for document: GiniVisionDocument) {
        if let index = pages.index(of: document) {
            pages[index].document = document
        }
    }
    
    func update(_ document: GiniVisionDocument, withError error: Error?, isUploaded: Bool) {
        if let index = pages.index(of: document) {
            pages[index].isUploaded = isUploaded
            pages[index].error = error
        }
        
        if giniConfiguration.multipageEnabled, pages.type == .image {
            refreshMultipageReviewNextButton(with: pages)
            multiPageReviewViewController.updateCollections(with: pages)
        }
    }
    
    func replaceDocuments(with pages: [GiniVisionPage]) {
        self.pages = pages
    }
    
    func clearDocuments() {
        pages.removeAll()
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
        self.screenAPINavigationController.pushViewController(HelpMenuViewController(giniConfiguration: giniConfiguration),
                                                              animated: true)
    }
    
    @objc func showAnalysisScreen() {
        guard let firstDocument = pages.first?.document else {
            return
        }
        
        if pages.type == .image {
            visionDelegate?.didReview(documents: pages.map { $0.document }, networkDelegate: self)
        }
        analysisViewController = createAnalysisScreen(withDocument: firstDocument)
        
        if let (message, action) = analysisErrorAndAction {
            displayError(withMessage: message, andAction: action)
        }
        
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
        if fromVC is AnalysisViewController {
            analysisViewController = nil
            if operation == .pop {
                visionDelegate?.didCancelAnalysis()
            }
        }
        
        if fromVC is ReviewViewController && operation == .pop {
            // This can only happen when not using multipage
            reviewViewController = nil
            
            if let firstDocument = pages.first?.document {
                visionDelegate?.didCancelReview(for: firstDocument)
            }
        }
        
        if toVC is CameraViewController &&
            (fromVC is ReviewViewController ||
             fromVC is AnalysisViewController ||
             fromVC is ImageAnalysisNoResultsViewController) {
            // When going directly from the analysis or from the single page review screen to the camera the pages
            // collection should be cleared, since the document processed in that cases is not going to be reused
            clearDocuments()
            documentService?.resetToInitialState()
        }
        
        let isFromCameraToMultipage = (toVC is MultipageReviewViewController && fromVC is CameraViewController)
        let isFromMultipageToCamera = (fromVC is MultipageReviewViewController && toVC is CameraViewController)
        
        if isFromCameraToMultipage || isFromMultipageToCamera {
            return multipageTransition(operation: operation, from: fromVC, to: toVC)
        }
        
        return nil
    }
    
    private func multipageTransition(operation: UINavigationControllerOperation,
                                     from fromVC: UIViewController,
                                     to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let stackView = cameraViewController?.capturedImagesStackView else {
            return nil
        }
        
        multiPageTransition.originFrame = stackView
            .thumbnailFrameRelative(to: screenAPINavigationController.view)
        multiPageTransition.operation = operation
        
        if let multipageVC = fromVC as? MultipageReviewViewController, let cameraVC = toVC as? CameraViewController {
            cameraVC.replaceCapturedStackImages(with: pages.compactMap { $0.document.previewImage })
            if let (image, frame) = multipageVC.visibleMainCollectionImage(from: screenAPINavigationController.view) {
                multiPageTransition.popImage = image
                multiPageTransition.popImageFrame = frame
            } else {
                return nil
            }
        }
        
        if stackView.isHidden && operation == .push {
            return nil
        } else {
            return multiPageTransition
        }
    }
}
