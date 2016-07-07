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
    private var closeButton = UIBarButtonItem()
    private var helpButton  = UIBarButtonItem()
    
    // Properties
    private var showHelp: (() -> ())?
    
    // Images
    private var closeButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "navigationCameraClose")
    }
    private var helpButtonImage: UIImage? {
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
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.navigationController?.pushViewController(GINIReviewContainerViewController(imageData: imageData), animated: true)
                })
            }, failure: { error in
                switch error {
                case .NotAuthorizedToUseDevice:
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
        closeButton = UIBarButtonItem(image: closeButtonImage, style: .Plain, target: self, action: #selector(close))
        closeButton.title = GINIConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton
        if let s = closeButton.title where !s.isEmpty {
            closeButton.image = nil
        } else {
            // Set title `nil` because an empty string will cause problems in UI
            closeButton.title = nil
        }
        
        // Configure help button
        helpButton = UIBarButtonItem(image: helpButtonImage, style: .Plain, target: self, action: #selector(help))
        helpButton.title = GINIConfiguration.sharedConfiguration.navigationBarCameraTitleHelpButton
        if let s = helpButton.title where !s.isEmpty {
            helpButton.image = nil
        } else {
            // Set title `nil` because an empty string will cause problems in UI
            helpButton.title = nil
        }
        
        // Configure view hierachy
        view.addSubview(containerView)
        navigationItem.setLeftBarButtonItem(closeButton, animated: false)
        navigationItem.setRightBarButtonItem(helpButton, animated: false)
        
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
           !NSUserDefaults.standardUserDefaults().boolForKey("ginivision.defaults.onboardingShowed") {
            showHelp = help
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "ginivision.defaults.onboardingShowed")
        } else if GINIConfiguration.sharedConfiguration.onboardingShowAtLaunch {
            showHelp = help
        }
    }
    
    override func viewDidAppear(animated: Bool) {
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
        navigationController.modalPresentationStyle = .OverCurrentContext
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
    }

}
