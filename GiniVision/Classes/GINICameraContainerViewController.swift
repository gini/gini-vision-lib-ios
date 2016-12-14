//
//  CameraContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 08/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class GINICameraContainerViewController: UIViewController, GINIContainer {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // User interface
    fileprivate var closeButton = UIBarButtonItem()
    fileprivate var helpButton  = UIBarButtonItem()
    
    // Properties
    fileprivate var showHelp: (() -> ())?
    
    // Images
    fileprivate var closeButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationCameraClose")
    }
    fileprivate var helpButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationCameraHelp")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // Configure content controller and call delegate method on success
        contentController = GINICameraViewController(success:
            { imageData in
                let delegate = (self.navigationController as? GININavigationViewController)?.giniDelegate
                delegate?.didCapture(imageData)
                
                // Push review container view controller
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(GINIReviewContainerViewController(imageData: imageData), animated: true)
                }
            }, failure: { error in
                switch error {
                case .notAuthorizedToUseDevice:
                    print("GiniVision: Camera authorization denied.")
                default:
                    print("GiniVision: Unknown error when using camera.")
                }
            })
        
        // Configure title
        title = GINIConfiguration.sharedConfiguration.navigationBarCameraTitle
                
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        closeButton = GINIBarButtonItem(
            image: closeButtonImage,
            title: GINIConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton,
            style: .plain,
            target: self,
            action: #selector(close)
        )
        
        // Configure help button
        helpButton = GINIBarButtonItem(
            image: helpButtonImage,
            title: GINIConfiguration.sharedConfiguration.navigationBarCameraTitleHelpButton,
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
        if GINIConfiguration.sharedConfiguration.onboardingShowAtFirstLaunch &&
           !UserDefaults.standard.bool(forKey: "ginivision.defaults.onboardingShowed") {
            showHelp = help
            UserDefaults.standard.set(true, forKey: "ginivision.defaults.onboardingShowed")
        } else if GINIConfiguration.sharedConfiguration.onboardingShowAtLaunch {
            showHelp = help
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showHelp?()
        showHelp = nil
    }
    
    @IBAction func close() {
        let delegate = (navigationController as? GININavigationViewController)?.giniDelegate
        delegate?.didCancelCapturing()
        
        // Reset configuration when Gini Vision Library is closed
        GINIConfiguration.sharedConfiguration = GINIConfiguration()
    }
    
    @IBAction func help() {
        let cameraViewController = contentController as? GINICameraViewController
        
        // Hide camera UI when overlay is shown
        cameraViewController?.hideCameraOverlay()
        cameraViewController?.hideCaptureButton()
        let vc = GINIOnboardingContainerViewController {
            
            // Show camera UI when overlay is dismissed
            cameraViewController?.showCameraOverlay()
            cameraViewController?.showCaptureButton()
        }
        let navigationController = GININavigationViewController(rootViewController: vc)
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

}
