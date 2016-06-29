//
//  GINICameraViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 08/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation

/**
 Block which will be executed when the camera successfully takes a picture. It contains the JPEG representation of the image including meta information about the image.

 - note: Component API only.
 */
public typealias GINICameraSuccessBlock = (imageData: NSData) -> ()

/**
 Block which will be executed when an error occurs on the camera screen. It contains a camera specific error.

 - note: Component API only.
 */
public typealias GINICameraErrorBlock = (error: GINICameraError) -> ()

/**
 The `GINICameraViewController` provides a custom camera screen which enables the user to take a photo of a document to be analyzed. The user can focus the camera manually if the auto focus does not work.
 
 **Text ressources on this screen**
 
 * `ginivision.navigationbar.camera.title` (Screen API only.)
 * `ginivision.navigationbar.camera.close` (Screen API only.)
 * `ginivision.navigationbar.camera.help` (Screen API only.)
 
 **Image ressources on this screen**
 
 * `cameraCaptureButton`
 * `cameraCaptureButtonActive`
 * `cameraFocusLarge`
 * `cameraFocusSmall`
 * `cameraOverlay`
 * `navigationCameraClose` (Screen API only.)
 * `navigationCameraHelp` (Screen API only.)
 
 Ressources listed also contain ressources for the container view controller. They are marked with _Screen API only_.
 
 - note: Component API only.
 */
public final class GINICameraViewController: UIViewController {
    
    // User interface
    private var controlsView  = UIView()
    private var previewView   = GINICameraPreviewView()
    private var cameraOverlay = UIImageView()
    private var captureButton = UIButton()
    private var focusIndicatorImageView: UIImageView?
    private var defaultImageView: UIImageView?
    
    // Properties
    private var camera: GINICamera?
    
    // Images
    private var defaultImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraDefaultDocumentImage")
    }
    private var captureButtonNormalImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButton")
    }
    private var captureButtonActiveImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButtonActive")
    }
    private var cameraOverlayImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraOverlay")
    }
    private var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    private var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    
    // Output
    private var successBlock: GINICameraSuccessBlock?
    private var errorBlock: GINICameraErrorBlock?

    /**
     Designated intitializer for the `GINICameraViewController` which allows to set a success and error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when image was taken.
     - parameter failure: Error block to be exectued when an error occured.
     
     - returns: A view controller instance allowing the user to take a picture.
     */
    public init(success: GINICameraSuccessBlock, failure: GINICameraErrorBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        successBlock = success
        errorBlock = failure
        
        // Configure camera
        do {
            camera = try GINICamera()
        } catch let error as GINICameraError {
            switch error {
            case .NotAuthorizedToUseDevice:
                print("Camera not authorized add option to go to Settings app")
            default:
                if GINIConfiguration.DEBUG { addDefaultImage() }
            }
            failure(error: error)
        } catch _ {
            print("GiniVision: An unkown error occured.")
        }
        
        // Configure preview view
        if let validCamera = camera {
            previewView.session = validCamera.session
        }
        (previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
        previewView.addGestureRecognizer(tapGesture)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(subjectAreaDidChange), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: camera?.videoDeviceInput?.device)
        
        // Configure camera overlay
        cameraOverlay.image = cameraOverlayImage
        cameraOverlay.contentMode = .ScaleAspectFit
        
        // Configure capture button
        captureButton.setImage(captureButtonNormalImage, forState: .Normal)
        captureButton.setImage(captureButtonActiveImage, forState: .Highlighted)
        captureButton.addTarget(self, action: #selector(captureImage), forControlEvents: .TouchUpInside)
        
        // Configure colors
        view.backgroundColor = UIColor.clearColor()
        previewView.backgroundColor = UIColor.clearColor()
        controlsView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        captureButton.backgroundColor = UIColor.clearColor()
        cameraOverlay.backgroundColor = UIColor.clearColor()
        
        // Configure view hierachy
        view.addSubview(previewView)
        view.addSubview(cameraOverlay)
        view.addSubview(controlsView)
        controlsView.addSubview(captureButton)
        
        // Add constraints
        addConstraints()
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     - parameter animated: If `true`, the view is being added to the window using an animation.
     */
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        camera?.start()
    }
    
    /**
     Notifies the view controller that its view is about to be removed from a view hierarchy.
     
     - parameter animated: If `true`, the disappearance of the view is being animated.
     */
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera?.stop()
    }
    
    // MARK: Toggle UI elements
    /**
     Show the capture button. Should be called when onboarding is dismissed.
     */
    public func showCaptureButton() {
        controlsView.alpha = 1
    }
    
    /**
     Hide the capture button. Should be called when onboarding is presented.
     */
    public func hideCaptureButton() {
        controlsView.alpha = 0
    }
    
    /**
     Show the camera overlay. Should be called when onboarding is dismissed.
     */
    public func showCameraOverlay() {
        cameraOverlay.alpha = 1
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        cameraOverlay.alpha = 0
    }
    
    // MARK: Image capture
    @objc private func captureImage(sender: AnyObject) {
        guard let camera = camera else {
            if GINIConfiguration.DEBUG {
                // Retrieve image from default image view to make sure image was set and therefor the correct states were checked before.
                if let image = self.defaultImageView?.image,
                   let imageData = UIImageJPEGRepresentation(image, 1) {
                    self.successBlock?(imageData: imageData)
                }
            }
            return print("GiniVision: No camera initialized.")
        }
        camera.captureStillImage { inner in
            do {
                let imageData = try inner()
                // Call success block
                self.successBlock?(imageData: imageData)
            } catch let error as GINICameraError {
                self.errorBlock?(error: error)
            } catch _ {
                print("GiniVision: An unkown error occured.")
            }
        }
        
    }
    
    // MARK: Focus handling
    @objc private func focusAndExposeTap(sender: UITapGestureRecognizer) {
        let devicePoint = (previewView.layer as! AVCaptureVideoPreviewLayer).captureDevicePointOfInterestForPoint(sender.locationInView(sender.view))
        camera?.focusWithMode(.AutoFocus, exposeWithMode: .AutoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
        let imageView = createFocusIndicator(withImage: cameraFocusSmall, atPoint: (previewView.layer as! AVCaptureVideoPreviewLayer).pointForCaptureDevicePointOfInterest(devicePoint))
        showFocusIndicator(imageView)
    }
    
    @objc private func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPointMake(0.5, 0.5)
        camera?.focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
        let imageView = createFocusIndicator(withImage: cameraFocusLarge, atPoint: (previewView.layer as! AVCaptureVideoPreviewLayer).pointForCaptureDevicePointOfInterest(devicePoint))
        showFocusIndicator(imageView)
    }
    
    private func createFocusIndicator(withImage image: UIImage?, atPoint point: CGPoint) -> UIImageView? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.center = point
        return imageView
    }
    
    private func showFocusIndicator(imageView: UIImageView?) {
        guard let imageView = imageView else { return }
        for subView in self.previewView.subviews {
            subView.removeFromSuperview()
        }
        self.previewView.addSubview(imageView)
        UIView.animateWithDuration(1.5,
                                   animations: {
                                    imageView.alpha = 0.0
            },
                                   completion: { (success: Bool) -> Void in
                                    imageView.removeFromSuperview()
        })
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view
        
        // Preview view
        previewView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: previewView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: previewView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: previewView, attribute: .Width, relatedBy: .Equal, toItem: previewView, attribute: .Height, multiplier: 3/4, constant: 0)
        UIViewController.addActiveConstraint(item: previewView, attribute: .Width, relatedBy: .Equal, toItem: superview, attribute: .Width, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: previewView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: superview, attribute: .Width, multiplier: 1, constant: 0, priority: 999)
        UIViewController.addActiveConstraint(item: previewView, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: 0)
        
        // Camera overlay view
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: cameraOverlay, attribute: .Top, relatedBy: .Equal, toItem: previewView, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: cameraOverlay, attribute: .Trailing, relatedBy: .Equal, toItem: previewView, attribute: .Trailing, multiplier: 1, constant: -23)
        UIViewController.addActiveConstraint(item: cameraOverlay, attribute: .Bottom, relatedBy: .Equal, toItem: previewView, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: cameraOverlay, attribute: .Leading, relatedBy: .Equal, toItem: previewView, attribute: .Leading, multiplier: 1, constant: 23)
        
        // Controls view
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: controlsView, attribute: .Top, relatedBy: .Equal, toItem: previewView, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: controlsView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: controlsView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: controlsView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: controlsView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: captureButton, attribute: .Height, multiplier: 1.1, constant: 0)
        
        // Capture button
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: captureButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 55)
        UIViewController.addActiveConstraint(item: captureButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 55)
        UIViewController.addActiveConstraint(item: captureButton, attribute: .CenterX, relatedBy: .Equal, toItem: controlsView, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: captureButton, attribute: .CenterY, relatedBy: .Equal, toItem: controlsView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
    /// Adds a default image to the canvas when no camera is available (DEBUG mode only)
    private func addDefaultImage() {
        defaultImageView = UIImageView(image: defaultImage)
        guard let defaultImageView = defaultImageView else { return }
        
        defaultImageView.contentMode = .ScaleAspectFit
        previewView.addSubview(defaultImageView)
        
        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .Width, relatedBy: .Equal, toItem: previewView, attribute: .Width, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .Height, relatedBy: .Equal, toItem: previewView, attribute: .Height, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .CenterX, relatedBy: .Equal, toItem: previewView, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .CenterY, relatedBy: .Equal, toItem: previewView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
}

