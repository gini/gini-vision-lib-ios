//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

internal final class GiniScreenAPICoordinator: NSObject, Coordinator {
    
    var childCoordinators: [Coordinator] = []
    lazy var rootViewController: UIViewController = {
        return self.containerNavigationController!
    }()
    
    fileprivate lazy var containerNavigationController: ContainerNavigationController? =
        ContainerNavigationController(rootViewController: self.screenAPINavigationController,
                                      parent: self)
    fileprivate lazy var screenAPINavigationController: UINavigationController = {
        let navigationController = UINavigationController()
        navigationController.delegate = self
        navigationController.applyStyle(withConfiguration: self.giniConfiguration)
        return navigationController
    }()
    fileprivate lazy var cameraViewController: CameraViewController =
        self.setupCameraViewController()
    fileprivate lazy var reviewViewController: ReviewViewController =
        self.setupReviewScreen(withDocument: self.visionDocument!)
    fileprivate lazy var analysisViewController: AnalysisViewController =
        self.setupAnalysisScreen(withDocument: self.visionDocument!)
    fileprivate lazy var imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController =
        self.setupImageAnalysisNoResultsScreen()
    
    fileprivate weak var visionDelegate: GiniVisionDelegate?
    fileprivate var giniConfiguration: GiniConfiguration
    fileprivate var visionDocument: GiniVisionDocument?
    fileprivate var noticeView: NoticeView?
    fileprivate var changesOnReview: Bool = false
    fileprivate enum NavBarItemPosition {
        case left, right
    }
    
    // Resources
    fileprivate lazy var analysisBackButtonResources =
        PreferredButtonResource(image: "navigationAnalysisBack",
                                title: "ginivision.navigationbar.analysis.back",
                                comment: "Button title in the navigation bar for" +
            "the back button on the analysis screen",
                                configEntry: self.giniConfiguration.navigationBarAnalysisTitleBackButton)
    fileprivate lazy var cameraCloseButtonResources =
        PreferredButtonResource(image: "navigationCameraClose",
                                title: "ginivision.navigationbar.camera.close",
                                comment: "Button title in the navigation bar for the close button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate lazy var cameraHelpButtonResources =
        PreferredButtonResource(image: "navigationCameraHelp",
                                title: "ginivision.navigationbar.camera.help",
                                comment: "Button title in the navigation bar for the help button on the camera screen",
                                configEntry: self.giniConfiguration.navigationBarCameraTitleHelpButton)
    
    fileprivate lazy var reviewContinueButtonResources =
        PreferredButtonResource(image: "navigationReviewContinue",
                                title: "ginivision.navigationbar.review.continue",
                                comment: "Button title in the navigation bar for " +
                                         "the continue button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleContinueButton)
    
    fileprivate lazy var reviewBackButtonResources =
        PreferredButtonResource(image: "navigationReviewBack",
                                title: "ginivision.navigationbar.review.back",
                                comment: "Button title in the navigation bar for the back button on the review screen",
                                configEntry: self.giniConfiguration.navigationBarReviewTitleBackButton)
    
    init(withDelegate delegate: GiniVisionDelegate,
         document: GiniVisionDocument?,
         giniConfiguration: GiniConfiguration) {
        self.visionDelegate = delegate
        self.giniConfiguration = giniConfiguration
        self.visionDocument = document
        super.init()
        self.setupFirstScreen(withDocument: document)
    }
}

// MARK: - Private methods

extension GiniScreenAPICoordinator {
    fileprivate func setupFirstScreen(withDocument document: GiniVisionDocument?) {
        let viewController: UIViewController
        if let document = document {
            if !giniConfiguration.openWithEnabled {
                fatalError("You are trying to import a file from other app when the Open With feature is not enabled." +
                    "To enable it just set `openWithEnabled` to `true` in the `GiniConfiguration`")
            }
            
            if document.isReviewable {
                viewController = self.reviewViewController
            } else {
                viewController = self.analysisViewController
            }
            self.didCapture(withDocument: document)
        } else {
            viewController = self.cameraViewController
        }
        
        self.screenAPINavigationController.setViewControllers([viewController], animated: false)
    }
    
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
            self.close()
        } else {
            self.screenAPINavigationController.popViewController(animated: true)
        }
    }
    
    @objc fileprivate func close() {
        self.containerNavigationController?.coordinator = nil
        self.visionDelegate?.didCancelCapturing()
    }
    
    @objc fileprivate func showHelpMenu() {
        self.screenAPINavigationController.pushViewController(HelpMenuViewController(), animated: true)
    }
    
    @objc fileprivate func goToAnalysis() {
        if let didReview = visionDelegate?.didReview(document:withChanges:) {
            didReview(visionDocument!, changesOnReview)
        } else if let didReview = visionDelegate?.didReview(_:withChanges:) {
            didReview(visionDocument!.data, changesOnReview)
        } else {
            fatalError("GiniVisionDelegate.didReview(document: GiniVisionDocument," +
                "withChanges changes: Bool) should be implemented")
        }
        
        self.screenAPINavigationController.pushViewController(analysisViewController, animated: true)
    }
    
    @objc fileprivate func backToCamera() {
        screenAPINavigationController.popToViewController(cameraViewController, animated: true)
    }
}

// MARK: - Navigation delegate

extension GiniScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC == analysisViewController && toVC == reviewViewController {
            visionDelegate?.didCancelAnalysis?()
        }
        if fromVC == reviewViewController && toVC == cameraViewController {
            visionDelegate?.didCancelReview?()
        }
        
        return nil
    }
}

// MARK: - Camera Screen

internal extension GiniScreenAPICoordinator {
    
    func setupCameraViewController() -> CameraViewController {
        let cameraViewController = CameraViewController(successBlock: { [weak self ] document in
            guard let `self` = self,
                let delegate = self.visionDelegate else {
                    return
            }
            self.visionDocument = document
            
            if let qrDocument = document as? GiniQRCodeDocument {
                if let didDetect = delegate.didDetect(qrDocument: ) {
                    didDetect(qrDocument)
                } else {
                    fatalError("QR Code scanning is enabled but `GiniVisionDelegate.didCapture`" +
                        "method wasn't implement")
                }
            } else {
                if document.isReviewable {
                    self.screenAPINavigationController.pushViewController(self.reviewViewController, animated: true)
                } else {
                    self.screenAPINavigationController.pushViewController(self.analysisViewController, animated: true)
                }
                self.didCapture(withDocument: document)
            }
            
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
        
        setupNavigationItem(usingResources: cameraCloseButtonResources,
                            selector: #selector(back),
                            position: .left,
                            onViewController: cameraViewController)
        
        setupNavigationItem(usingResources: cameraHelpButtonResources,
                            selector: #selector(showHelpMenu),
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
}

// MARK: - Review Screen

internal extension GiniScreenAPICoordinator {
    fileprivate func setupReviewScreen(withDocument document: GiniVisionDocument) -> ReviewViewController {
        let reviewViewController = ReviewViewController(document, successBlock: { [unowned self] document in
            self.visionDocument = document
            self.changesOnReview = true
            }, failureBlock: { error in
                print(error)
        })
        
        reviewViewController.title = giniConfiguration.navigationBarReviewTitle
        reviewViewController.view.backgroundColor = giniConfiguration.backgroundColor
        
        setupNavigationItem(usingResources: reviewContinueButtonResources,
                            selector: #selector(goToAnalysis),
                            position: .right,
                            onViewController: reviewViewController)
        
        setupNavigationItem(usingResources: reviewBackButtonResources,
                            selector: #selector(back),
                            position: .left,
                            onViewController: reviewViewController)
        
        return reviewViewController
    }
}

// MARK: - Analysis Screen

internal extension GiniScreenAPICoordinator {
    fileprivate func setupAnalysisScreen(withDocument document: GiniVisionDocument) -> AnalysisViewController {
        let viewController = AnalysisViewController(document)
        viewController.view.backgroundColor = giniConfiguration.backgroundColor
        viewController.didShowAnalysis = { [weak self] in
            guard let `self` = self else { return }
            self.visionDelegate?.didShowAnalysis?(self)
            self.analysisViewController.showAnimation()
        }
        setupNavigationItem(usingResources: self.analysisBackButtonResources,
                            selector: #selector(back),
                            position: .left,
                            onViewController: viewController)
        return viewController
    }
    
    fileprivate func show(notice: NoticeView) {
        if noticeView != nil {
            noticeView?.hide(completion: {
                self.noticeView = nil
                self.show(notice: notice)
            })
        } else {
            noticeView = notice
            analysisViewController.view.addSubview(noticeView!)
            noticeView?.show()
        }
    }
}

// MARK: - Onboarding Screen

extension GiniScreenAPICoordinator {
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
        cameraViewController.hideCameraOverlay()
        cameraViewController.hideCaptureButton()
        cameraViewController.hideFileImportTip()
        
        let vc = OnboardingContainerViewController { [weak self] in
            guard let `self` = self else { return }
            self.cameraViewController.showCameraOverlay()
            self.cameraViewController.showCaptureButton()
            self.cameraViewController.showFileImportTip()
        }
        
        let navigationController = GiniNavigationViewController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overCurrentContext
        screenAPINavigationController.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    fileprivate func setupImageAnalysisNoResultsScreen() -> ImageAnalysisNoResultsViewController {
        let imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController
        let isCameraViewControllerLoaded = screenAPINavigationController.viewControllers.contains(cameraViewController)
        
        if isCameraViewControllerLoaded {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController()
            setupNavigationItem(usingResources: reviewBackButtonResources,
                                selector: #selector(backToCamera),
                                position: .left,
                                onViewController: imageAnalysisNoResultsViewController)
        } else {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil,
                                                                                        bottomButtonIcon: nil)
            setupNavigationItem(usingResources: cameraCloseButtonResources,
                                selector: #selector(close),
                                position: .left,
                                onViewController: imageAnalysisNoResultsViewController)
        }
        
        imageAnalysisNoResultsViewController.view.backgroundColor = giniConfiguration.backgroundColor
        imageAnalysisNoResultsViewController.didTapBottomButton = { [weak self] in
            self?.backToCamera()
        }
        
        return imageAnalysisNoResultsViewController
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {
    func displayError(withMessage message: String?, andAction action: NoticeAction?) {
        let notice = NoticeView(text: message ?? "", noticeType: .error, action: action)
        DispatchQueue.main.async {
            self.show(notice: notice)
        }
    }
    
    func tryDisplayNoResultsScreen() -> Bool {
        if let visionDocument = visionDocument, visionDocument.type == .image {
            screenAPINavigationController.pushViewController(imageAnalysisNoResultsViewController, animated: true)
            return true
        }
        return false
    }
}

