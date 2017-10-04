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
    fileprivate var showHelp: (() -> ())?
    
    // Resources
    fileprivate let closeButtonResources = PreferredButtonResource(image: "navigationCameraClose", title: "ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate let helpButtonResources = PreferredButtonResource(image: "navigationCameraHelp", title: "ginivision.navigationbar.camera.help", comment: "Button title in the navigation bar for the help button on the camera screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleHelpButton)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Configure content controller and call delegate method on success
        contentController = CameraViewController(successBlock:
            { document, isImported in
                let delegate = (self.navigationController as? GiniNavigationViewController)?.giniDelegate
                let viewController:UIViewController
                if isImported {
                    if document.isReviewable {
                        viewController = ReviewContainerViewController(document: document)
                    } else {
                        viewController = AnalysisContainerViewController(document: document)
                    }
                    delegate?.didImport?(document)
                } else {
                    viewController = ReviewContainerViewController(document: document)
                    delegate?.didCapture(document.data)
                }
                
                // Push review container view controller
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                
        }, failureBlock: {[unowned self] error in
            switch error {
            case CameraError.notAuthorizedToUseDevice:
                print("GiniVision: Camera authorization denied.")
            case CameraError.notAuthorizedToAccessPhotoLibrary:
                self.showPhotoLibraryPermissionDeniedError()
            case is DocumentValidationError:
                self.showNotValidDocumentError()
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
            action: #selector(help)
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
            showHelp = help
            UserDefaults.standard.set(true, forKey: "ginivision.defaults.onboardingShowed")
        } else if GiniConfiguration.sharedConfiguration.onboardingShowAtLaunch {
            showHelp = help
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showHelp?()
        showHelp = nil
    }
    
    @IBAction func close() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelCapturing()
        
        // Reset configuration when Gini Vision Library is closed
        GiniConfiguration.sharedConfiguration = GiniConfiguration()
    }
    
    @IBAction func help() {
        let cameraViewController = contentController as? CameraViewController
        
        // Hide camera UI when overlay is shown
        cameraViewController?.hideCameraOverlay()
        cameraViewController?.hideCaptureButton()
        let vc = OnboardingContainerViewController {
            
            // Show camera UI when overlay is dismissed
            cameraViewController?.showCameraOverlay()
            cameraViewController?.showCaptureButton()
        }
        let navigationController = GiniNavigationViewController(rootViewController: vc)
        navigationController.modalPresentationStyle = .overCurrentContext
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
    }
    
    // MARK: Error dialogs
    fileprivate func showNotValidDocumentError() {
        let alertViewController = UIAlertController(title: "Ungültiges Dokument", message: "Das von Ihnen gewählte Dokument ist ungültig", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        self.contentController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showPhotoLibraryPermissionDeniedError() {
        let alertMessage = NSLocalizedString("ginivision.camera.notAuthorizedPhotoLibrary",bundle: Bundle(for: GiniVision.self), comment: "This message is shown when Photo library permission is denied")
        
        let alertViewController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        alertViewController.addAction(UIAlertAction(title: "Zugriff erteilen", style: .default, handler: {[unowned self] _ in
            alertViewController.dismiss(animated: true, completion: nil)
            self.openAppSettings()
        }))
        
        self.contentController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.openURL(settingsUrl)
        }
    }
    
}
