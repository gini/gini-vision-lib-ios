//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

internal final class GiniScreenAPICoordinator: NSObject {
    
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
    
    // Properties
    fileprivate var changesOnReview: Bool = false
    fileprivate var giniConfiguration: GiniConfiguration
    fileprivate weak var visionDelegate: GiniVisionDelegate?
    fileprivate var visionDocument: GiniVisionDocument?
    fileprivate var imageDocuments: [GiniImageDocument] = []
    fileprivate let multipageTransition = MultipageReviewTransitionAnimator()
    
    lazy var vc: UIViewController = {
        let nav = UINavigationController(rootViewController: MultipageReviewController(imageDocuments: self.imageDocuments))
        nav.transitioningDelegate = self
        return nav
    }()
    
    fileprivate enum NavBarItemPosition {
        case left, right
    }
    
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
    
    func start(withDocument document: GiniVisionDocument?) -> UIViewController {
        self.visionDocument = document
        let viewController: UIViewController
        if let document = document {
            if !giniConfiguration.openWithEnabled {
                fatalError("You are trying to import a file from other app when the Open With feature is not enabled." +
                    "To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
            }
            
            if document.isReviewable {
                self.reviewViewController = self.createReviewScreen(withDocument: document, isFirstScreen: true)
                viewController = self.reviewViewController!
            } else {
                self.analysisViewController = self.createAnalysisScreen(withDocument: document)
                viewController = self.analysisViewController!
            }
            self.didCapture(withDocument: document)
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
    
    fileprivate func setupNavigationItem(usingResources preferredResources: PreferredButtonResource,
                                         selector: Selector,
                                         position: NavBarItemPosition,
                                         onViewController viewController: UIViewController) {
        let buttonText = preferredResources.preferredText
        if buttonText != nil && !buttonText!.isEmpty {
            let navButton = GiniBarButtonItem(
                image: preferredResources.preferredImage,
                title: buttonText,
                style: .plain,
                target: self,
                action: selector
            )
            switch position {
            case .right:
                viewController.navigationItem.setRightBarButton(navButton, animated: false)
            case .left:
                viewController.navigationItem.setLeftBarButton(navButton, animated: false)
            }
        }
    }
    
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
        if let didReview = visionDelegate?.didReview(document:withChanges:) {
            didReview(visionDocument!, changesOnReview)
        } else if let didReview = visionDelegate?.didReview(_:withChanges:) {
            didReview(visionDocument!.data, changesOnReview)
        } else {
            fatalError("GiniVisionDelegate.didReview(document: GiniVisionDocument," +
                "withChanges changes: Bool) should be implemented")
        }
        
        self.analysisViewController = createAnalysisScreen(withDocument: visionDocument!)
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
        if visionDocument != nil {
            if fromVC == analysisViewController && operation == .pop {
                analysisViewController = nil
                visionDelegate?.didCancelAnalysis?()
            }
            if fromVC == reviewViewController && toVC == cameraViewController {
                reviewViewController = nil
                visionDelegate?.didCancelReview?()
            }
        }
        
        return nil
    }
}

extension GiniScreenAPICoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let reviewImagesButtonCenter = cameraViewController?.reviewImagesButton.center,
            let origin = cameraViewController?.reviewContentView.convert(reviewImagesButtonCenter,
                                                                         to: cameraViewController?.view),
            let size = cameraViewController?.reviewImagesButton.frame.size {
            multipageTransition.originFrame = CGRect(origin: origin, size: size)
            return multipageTransition
        }
        return nil
    }
}

// MARK: - Camera Screen

internal extension GiniScreenAPICoordinator {
    func createCameraViewController() -> CameraViewController {
        let cameraViewController = CameraViewController(successBlock: { [weak self ] document in
            guard let `self` = self else { return }
            self.visionDocument = document
            if let document = document as? GiniImageDocument, document.isReviewable {
//                self.reviewViewController = self.createReviewScreen(withDocument: document)
//                self.screenAPINavigationController.pushViewController(self.reviewViewController!, animated: true)
                self.imageDocuments.append(document)
            } else {
                self.analysisViewController = self.createAnalysisScreen(withDocument: document)
                self.screenAPINavigationController.pushViewController(self.analysisViewController!, animated: true)
            }
            self.didCapture(withDocument: document)
            
            }, failureBlock: { error in
                switch error {
                case CameraError.notAuthorizedToUseDevice:
                    print("GiniVision: Camera authorization denied.")
                default:
                    print("GiniVision: Unknown error when using camera.")
                }
        })
        
        cameraViewController.title = giniConfiguration.navigationBarCameraTitle
        cameraViewController.view.backgroundColor = giniConfiguration.backgroundColor
        cameraViewController.didShowCamera = {[weak self] in
            guard let `self` = self else { return }
            self.showOnboardingIfNeeded()
        }

        cameraViewController.didTapMultipageReviewButton = {[weak self] in
            guard let `self` = self else { return }

            self.screenAPINavigationController.present(self.vc,
                                                       animated: true,
                                                       completion: nil)
        }
        
        setupNavigationItem(usingResources: closeButtonResource,
                            selector: #selector(back),
                            position: .left,
                            onViewController: cameraViewController)
        
        setupNavigationItem(usingResources: helpButtonResource,
                            selector: #selector(showHelpMenuScreen),
                            position: .right,
                            onViewController: cameraViewController)
        
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
            self.visionDocument = document
            self.changesOnReview = true
            }, failureBlock: { _ in
        })
        
        reviewViewController.title = giniConfiguration.navigationBarReviewTitle
        reviewViewController.view.backgroundColor = giniConfiguration.backgroundColor
        
        setupNavigationItem(usingResources: nextButtonResource,
                            selector: #selector(showAnalysisScreen),
                            position: .right,
                            onViewController: reviewViewController)
        
        let backResource = isFirstScreen ? closeButtonResource : backButtonResource
        setupNavigationItem(usingResources: backResource,
                            selector: #selector(back),
                            position: .left,
                            onViewController: reviewViewController)
        
        return reviewViewController
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
        setupNavigationItem(usingResources: self.cancelButtonResource,
                            selector: #selector(back),
                            position: .left,
                            onViewController: viewController)
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
            setupNavigationItem(usingResources: backButtonResource,
                                selector: #selector(backToCamera),
                                position: .left,
                                onViewController: imageAnalysisNoResultsViewController)
        } else {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil,
                                                                                        bottomButtonIcon: nil)
            setupNavigationItem(usingResources: closeButtonResource,
                                selector: #selector(closeScreenApi),
                                position: .left,
                                onViewController: imageAnalysisNoResultsViewController)
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
        if let visionDocument = visionDocument, visionDocument.type == .image {
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

