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

//swiftlint:disable file_length
internal final class GiniScreenAPICoordinator: NSObject, Coordinator {
    
    var rootViewController: UIViewController {
        return screenAPINavigationController
    }
    
    fileprivate lazy var screenAPINavigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.delegate = self
        navigationController.applyStyle(withConfiguration: self.giniConfiguration)
        return navigationController
    }()
    
    // Screens
    fileprivate var analysisViewController: AnalysisViewController?
    fileprivate var cameraViewController: CameraViewController?
    fileprivate var imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController?
    fileprivate var reviewViewController: ReviewViewController?
    fileprivate var multiPageReviewController: MultipageReviewController?
    
    // Properties
    fileprivate var changesOnReview: Bool = false
    fileprivate var giniConfiguration: GiniConfiguration
    fileprivate let multiPageTransition = MultipageReviewTransitionAnimator()
    weak var visionDelegate: GiniVisionDelegate?
    var visionDocuments: [GiniVisionDocument] = []
    
    // Resources
    fileprivate lazy var backButtonResource =
        PreferredButtonResource(image: "navigationReviewBack",
                                title: "ginivision.navigationbar.review.back",
                                comment: "Button title in the navigation bar for the back button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleBackButton)
    fileprivate lazy var cancelButtonResource =
        PreferredButtonResource(image: "navigationAnalysisBack",
                                title: "ginivision.navigationbar.analysis.back",
                                comment: "Button title in the navigation bar for" +
            "the back button on the analysis screen",
                                configEntry: self.giniConfiguration.navigationBarAnalysisTitleBackButton)
    fileprivate lazy var closeButtonResource =
        PreferredButtonResource(image: "navigationCameraClose",
                                title: "ginivision.navigationbar.camera.close",
                                comment: "Button title in the navigation bar for the close button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate lazy var helpButtonResource =
        PreferredButtonResource(image: "navigationCameraHelp",
                                title: "ginivision.navigationbar.camera.help",
                                comment: "Button title in the navigation bar for the help button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleHelpButton)
    fileprivate lazy var nextButtonResource =
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
        let viewController: UIViewController
        if let documents = documents, !documents.isEmpty {
            self.visionDocuments = documents
            if !giniConfiguration.openWithEnabled {
                fatalError("You are trying to import a file from other app when the Open With feature is not enabled." +
                    "To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
            }
            
            if !documents.isAssorted {
                if documents[0].isReviewable {
                    self.reviewViewController = self.createReviewScreen(withDocument: documents[0], isFirstScreen: true)
                    viewController = self.reviewViewController!
                } else {
                    self.analysisViewController = self.createAnalysisScreen(withDocument: documents[0])
                    viewController = self.analysisViewController!
                }
            } else {
                //TODO: Decide on what to do with mixed arrays (PDF + images)
                self.cameraViewController = self.createCameraViewController()
                viewController = self.cameraViewController!
            }
            
        } else {
            self.cameraViewController = self.createCameraViewController()
            viewController = self.cameraViewController!
        }
        
        self.screenAPINavigationController.setViewControllers([viewController], animated: false)
        return ContainerNavigationController(rootViewController: self.screenAPINavigationController,
                                             parent: self)
    }
}

// MARK: - Private methods

extension GiniScreenAPICoordinator {
    
    @objc fileprivate func back() {
        if self.screenAPINavigationController.viewControllers.count == 1 {
            self.closeScreenApi()
        } else {
            self.screenAPINavigationController.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func closeScreenApi() {
        self.visionDelegate?.didCancelCapturing()
    }
    
    @objc fileprivate func showHelpMenuScreen() {
        self.screenAPINavigationController.pushViewController(HelpMenuViewController(), animated: true)
    }
    
    @objc fileprivate func showAnalysisScreen() {
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
    
    @objc fileprivate func backToCamera() {
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
        if visionDocuments != nil {
            if fromVC == analysisViewController && operation == .pop {
                analysisViewController = nil
                visionDelegate?.didCancelAnalysis?()
            }
            if fromVC == reviewViewController && toVC == cameraViewController {
                reviewViewController = nil
                visionDelegate?.didCancelReview?()
            }
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
        
        if let multipageVC = fromVC as? MultipageReviewController, let cameraVC = toVC as? CameraViewController {
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

// MARK: - Camera Screen

extension GiniScreenAPICoordinator: CameraViewControllerDelegate {
    func camera(_ viewController: CameraViewController, didCaptureDocuments documents: [GiniVisionDocument]) {
        visionDocuments.append(contentsOf: documents)
        
        if let firstDocument = documents.first {
            switch firstDocument.type {
            case .image:
                if let imageDocuments = documents as? [GiniImageDocument], firstDocument.isImported {
                    showMultipageReview(withImageDocuments: imageDocuments)
                }
            case .qrcode, .pdf:
                analysisViewController = createAnalysisScreen(withDocument: firstDocument)
                screenAPINavigationController.pushViewController(analysisViewController!, animated: true)
                didCapture(withDocument: firstDocument)
            }
        }
    }
    
    func camera(_ viewController: CameraViewController, didFailCaptureWithError error: CameraError) {
        switch error {
        case .notAuthorizedToUseDevice:
            print("GiniVision: Camera authorization denied.")
        default:
            print("GiniVision: Unknown error when using camera.")
        }
    }
    
    func cameraDidAppear(_ viewController: CameraViewController) {
        showOnboardingIfNeeded()
    }
    
    func cameraDidTapMultipageReviewButton(_ viewController: CameraViewController) {
        if let imageDocuments = visionDocuments as? [GiniImageDocument] {
            showMultipageReview(withImageDocuments: imageDocuments)
        }
    }
    
    func createCameraViewController() -> CameraViewController {
        let cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        cameraViewController.delegate = self
        cameraViewController.title = giniConfiguration.navigationBarCameraTitle
        cameraViewController.view.backgroundColor = giniConfiguration.backgroundColor
        
        cameraViewController.setupNavigationItem(usingResources: closeButtonResource,
                                                 selector: #selector(back),
                                                 position: .left,
                                                 target: self)

        cameraViewController.setupNavigationItem(usingResources: helpButtonResource,
                                                 selector: #selector(showHelpMenuScreen),
                                                 position: .right,
                                                 target: self)

        return cameraViewController
    }
    
    fileprivate func didCapture(withDocument document: GiniVisionDocument) {
        if let didCapture = visionDelegate?.didCapture(document:) {
            didCapture(document)
        } else if let didCapture = visionDelegate?.didCapture(_:) {
            didCapture(document.data)
        } else {
            fatalError("GiniVisionDelegate.didCapture(document: GiniVisionDocument) should be implemented")
        }
    }
    
    fileprivate func showOnboardingIfNeeded() {
        if giniConfiguration.onboardingShowAtFirstLaunch &&
            !UserDefaults.standard.bool(forKey: "ginivision.defaults.onboardingShowed") {
            showOnboardingScreen()
            UserDefaults.standard.set(true, forKey: "ginivision.defaults.onboardingShowed")
        } else if giniConfiguration.onboardingShowAtLaunch {
            showOnboardingScreen()
        }
    }
    
    private func showOnboardingScreen() {
        cameraViewController?.hideCameraOverlay()
        cameraViewController?.hideCaptureButton()
        cameraViewController?.hideFileImportTip()
        
        let vc = OnboardingContainerViewController { [weak self] in
            guard let `self` = self else { return }
            self.cameraViewController?.showCameraOverlay()
            self.cameraViewController?.showCaptureButton()
            self.cameraViewController?.showFileImportTip()
        }
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.applyStyle(withConfiguration: giniConfiguration)
        navigationController.modalPresentationStyle = .overCurrentContext
        screenAPINavigationController.present(navigationController, animated: true, completion: nil)
    }
    
}

// MARK: - Review Screen

internal extension GiniScreenAPICoordinator {
    fileprivate func createReviewScreen(withDocument document: GiniVisionDocument,
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

internal extension GiniScreenAPICoordinator {
    fileprivate func createMultipageReviewScreenContainer(withImageDocuments documents: [GiniImageDocument]) -> MultipageReviewController {
        let vc = MultipageReviewController(imageDocuments: documents)
        
        vc.setupNavigationItem(usingResources: backButtonResource,
                               selector: #selector(closeMultipageScreen),
                               position: .left,
                               target: self)
        
        vc.setupNavigationItem(usingResources: nextButtonResource,
                               selector: #selector(showAnalysisScreen),
                               position: .right,
                               target: self)
        
        vc.didUpdateDocuments = { [weak self] newDocuments in
            guard let `self` = self else { return }
            self.visionDocuments = newDocuments
            if self.visionDocuments.isEmpty {
                self.closeMultipageScreen()
            }
        }
        return vc
    }
    
    @objc fileprivate func closeMultipageScreen() {
        self.screenAPINavigationController.popViewController(animated: true)
        self.multiPageReviewController = nil
    }
    
    fileprivate func showMultipageReview(withImageDocuments imageDocuments: [GiniImageDocument]) {
        multiPageReviewController = createMultipageReviewScreenContainer(withImageDocuments: imageDocuments)
        screenAPINavigationController.pushViewController(multiPageReviewController!,
                                                         animated: true)
    }
}

// MARK: - Analysis Screen

internal extension GiniScreenAPICoordinator {
    fileprivate func createAnalysisScreen(withDocument document: GiniVisionDocument) -> AnalysisViewController {
        let viewController = AnalysisViewController(document: document)
        viewController.view.backgroundColor = giniConfiguration.backgroundColor
        viewController.didShowAnalysis = { [weak self] in
            guard let `self` = self else { return }
            self.visionDelegate?.didShowAnalysis?(self)
        }
        viewController.setupNavigationItem(usingResources: self.cancelButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        return viewController
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    fileprivate func createImageAnalysisNoResultsScreen() -> ImageAnalysisNoResultsViewController {
        let imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController
        let isCameraViewControllerLoaded: Bool = {
            guard let cameraViewController = cameraViewController else {
                return false
            }
            return screenAPINavigationController.viewControllers.contains(cameraViewController)
        }()
        
        if isCameraViewControllerLoaded {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController()
            imageAnalysisNoResultsViewController.setupNavigationItem(usingResources: backButtonResource,
                                                                     selector: #selector(backToCamera),
                                                                     position: .left,
                                                                     target: self)
        } else {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil,
                                                                                        bottomButtonIcon: nil)
            imageAnalysisNoResultsViewController.setupNavigationItem(usingResources: closeButtonResource,
                                                                     selector: #selector(closeScreenApi),
                                                                     position: .left,
                                                                     target: self)
        }
        
        imageAnalysisNoResultsViewController.didTapBottomButton = { [weak self] in
            self?.backToCamera()
        }
        
        return imageAnalysisNoResultsViewController
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {
    func displayError(withMessage message: String?, andAction action: NoticeAction?) {
        DispatchQueue.main.async {
            let notice = NoticeView(text: message ?? "", noticeType: .error, action: action)
            self.show(notice: notice)
        }
    }
    
    func tryDisplayNoResultsScreen() -> Bool {
        if let visionDocument = visionDocuments.first, visionDocument.type == .image {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.imageAnalysisNoResultsViewController = self.createImageAnalysisNoResultsScreen()
                self.screenAPINavigationController.pushViewController(self.imageAnalysisNoResultsViewController!,
                                                                      animated: true)
            }
            
            return true
        }
        return false
    }
    
    private func show(notice: NoticeView) {
        let noticeView = analysisViewController?.view.subviews.flatMap { $0 as? NoticeView }.first
        if let noticeView = noticeView {
            noticeView.hide(completion: { [weak self] in
                self?.show(notice: notice)
            })
        } else {
            analysisViewController?.view.addSubview(notice)
            notice.show()
        }
    }
}
