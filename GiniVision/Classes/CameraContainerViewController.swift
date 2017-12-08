//
//  CameraContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 08/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class CameraContainerViewController: UIViewController, ContainerViewController {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User interface
    fileprivate var closeButton = UIBarButtonItem()
    fileprivate var helpButton  = UIBarButtonItem()
    
    // Properties
    fileprivate var showOnboarding: (() -> Void)?
    
    // Resources
    fileprivate let closeButtonResources = PreferredButtonResource(image: "navigationCameraClose",
                                                                   title: "ginivision.navigationbar.camera.close",
                                                                   comment: "Button title in the navigation bar for the close button on the camera screen",
                                                                   configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate let helpButtonResources = PreferredButtonResource(image: "navigationCameraHelp",
                                                                  title: "ginivision.navigationbar.camera.help",
                                                                  comment: "Button title in the navigation bar for the help button on the camera screen",
                                                                  configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleHelpButton)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Configure content controller and call delegate method on success
        contentController = CameraViewController(successBlock: { [weak self ] document in
            guard let `self` = self,
                let delegate = (self.navigationController as? GiniNavigationViewController)?.giniDelegate else {
                    return
            }
            
            if let qrDocument = document as? GiniQRCodeDocument {
                if let didDetect = delegate.didDetect(qrDocument: ) {
                    didDetect(qrDocument)
                } else {
                    fatalError("QR Code scanning is enabled but `GiniVisionDelegate.didCapture`" +
                        "method wasn't implement")
                }
            } else {
                self.showNextScreen(forDocument: document)
                
                if let didCapture = delegate.didCapture(document:) {
                    didCapture(document)
                } else if let didCapture = delegate.didCapture(_:) {
                    didCapture(document.data)
                } else {
                    fatalError("GiniVisionDelegate.didCapture(document: GiniVisionDocument) should be implemented")
                }
            }
            
            }, failureBlock: { error in
                switch error {
                case CameraError.notAuthorizedToUseDevice:
                    print("GiniVision: Camera authorization denied.")
                default:
                    print("GiniVision: Unknown error when using camera.")
                }
        })
        
        // Configure title
        title = GiniConfiguration.sharedConfiguration.navigationBarCameraTitle
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        closeButton = GiniBarButtonItem(
            image: closeButtonResources.preferredImage,
            title: closeButtonResources.preferredText,
            style: .plain,
            target: self,
            action: #selector(close)
        )
        
        // Configure help button
        helpButton = GiniBarButtonItem(
            image: helpButtonResources.preferredImage,
            title: helpButtonResources.preferredText,
            style: .plain,
            target: self,
            action: #selector(showHelpMenu)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        navigationItem.setLeftBarButton(closeButton, animated: false)
        navigationItem.setRightBarButton(helpButton, animated: false)
        
        // Add constraints
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add content to container view
        displayContent(contentController)
        
        // Eventually show onboarding
        if GiniConfiguration.sharedConfiguration.onboardingShowAtFirstLaunch &&
            !UserDefaults.standard.bool(forKey: "ginivision.defaults.onboardingShowed") {
            showOnboarding = showOnboardingScreen
            UserDefaults.standard.set(true, forKey: "ginivision.defaults.onboardingShowed")
        } else if GiniConfiguration.sharedConfiguration.onboardingShowAtLaunch {
            showOnboarding = showOnboardingScreen
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showOnboarding?()
        showOnboarding = nil
    }
    
    @IBAction func close() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelCapturing()
        
        // Reset configuration when Gini Vision Library is closed
        GiniConfiguration.sharedConfiguration = GiniConfiguration()
    }
    
    @IBAction func showHelpMenu() {
        let helpMenu = HelpMenuViewController()
        self.navigationController?.pushViewController(helpMenu, animated: true)
    }
    
    fileprivate func showOnboardingScreen() {
        let cameraViewController = contentController as? CameraViewController
        
        // Hide camera UI when overlay is shown
        cameraViewController?.hideCameraOverlay()
        cameraViewController?.hideCaptureButton()
        cameraViewController?.hideFileImportTip()
        
        let vc = OnboardingContainerViewController {
            
            // Show camera UI when overlay is dismissed
            cameraViewController?.showCameraOverlay()
            cameraViewController?.showCaptureButton()
            cameraViewController?.showFileImportTip()
            
        }
        let navigationController = GiniNavigationViewController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overCurrentContext
        present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func showNextScreen(forDocument document: GiniVisionDocument) {
        let viewController: UIViewController
        if document.isReviewable {
            viewController = ReviewContainerViewController(document: document)
        } else {
            viewController = AnalysisContainerViewController(document: document)
        }
        
        // Push review container view controller
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        Contraints.active(item: containerView, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        Contraints.active(item: containerView, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        Contraints.active(item: containerView, attr: .bottom, relatedBy: .equal, to: superview, attr: .bottom)
        Contraints.active(item: containerView, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
    }
}
