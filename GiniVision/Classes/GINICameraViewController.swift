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
public typealias GINICameraSuccessBlock = (_ imageData: Data) -> ()

/**
 Block which will be executed if an error occurs on the camera screen. It contains a camera specific error.

 - note: Component API only.
 */
public typealias GINICameraErrorBlock = (_ error: GINICameraError) -> ()

/**
 The `GINICameraViewController` provides a custom camera screen which enables the user to take a photo of a document to be analyzed. The user can focus the camera manually if the auto focus does not work.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.camera.title` (Screen API only.)
 * `ginivision.navigationbar.camera.close` (Screen API only.)
 * `ginivision.navigationbar.camera.help` (Screen API only.)
 * `ginivision.camera.captureButton`
 * `ginivision.camera.notAuthorized`
 * `ginivision.camera.notAuthorizedButton`
 
 **Image resources for this screen**
 
 * `cameraCaptureButton`
 * `cameraCaptureButtonActive`
 * `cameraFocusLarge`
 * `cameraFocusSmall`
 * `cameraOverlay`
 * `cameraNotAuthorizedIcon`
 * `navigationCameraClose` (Screen API only.)
 * `navigationCameraHelp` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. These are marked with _Screen API only_.
 
 - note: Component API only.
 */
@objc public final class GINICameraViewController: UIViewController {
    
    /**
    Image view used to display a camera overlay like corners or a frame.
    Use public methods `showCameraOverlay` and `hideCameraOverlay` to control visibility of overlay.
    */
    public var cameraOverlay = UIImageView()
    
    fileprivate enum CameraState {
        case valid, notValid
    }
    
    // User interface
    fileprivate var controlsView  = UIView()
    fileprivate var previewView   = GINICameraPreviewView()
    fileprivate var captureButton = UIButton()
    fileprivate var focusIndicatorImageView: UIImageView?
    fileprivate var defaultImageView: UIImageView?
    
    // Properties
    fileprivate var camera: GINICamera?
    fileprivate var cameraState = CameraState.notValid
    
    // Images
    fileprivate var defaultImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraDefaultDocumentImage")
    }
    fileprivate var captureButtonNormalImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButton")
    }
    fileprivate var captureButtonActiveImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButtonActive")
    }
    fileprivate var cameraOverlayImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraOverlay")
    }
    fileprivate var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    fileprivate var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    
    // Output
    fileprivate var successBlock: GINICameraSuccessBlock?
    fileprivate var errorBlock: GINICameraErrorBlock?

    /**
     Designated intitializer for the `GINICameraViewController` which allows to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when image was taken.
     - parameter failure: Error block to be exectued if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture.
     */
    public init(success: @escaping GINICameraSuccessBlock, failure: @escaping GINICameraErrorBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        successBlock = success
        errorBlock = failure
        
        // Configure camera
        do {
            camera = try GINICamera()
        } catch let error as GINICameraError {
            switch error {
            case .notAuthorizedToUseDevice:
                addNotAuthorizedView()
            default:
                if GINIConfiguration.DEBUG { cameraState = .valid; addDefaultImage() }
            }
            failure(error)
        } catch _ {
            print("GiniVision: An unknown error occured.")
        }
        
        // Configure preview view
        if let validCamera = camera {
            cameraState = .valid
            previewView.session = validCamera.session
            (previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
            previewView.addGestureRecognizer(tapGesture)
            NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: camera?.videoDeviceInput?.device)
        }
        
        
        // Configure camera overlay
        cameraOverlay.image = cameraOverlayImage
        cameraOverlay.contentMode = .scaleAspectFit
        
        // Configure capture button
        captureButton.setImage(captureButtonNormalImage, for: .normal)
        captureButton.setImage(captureButtonActiveImage, for: .highlighted)
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        captureButton.accessibilityLabel = GINIConfiguration.sharedConfiguration.cameraCaptureButtonTitle
        
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
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     - parameter animated: If `true`, the view is added to the window using an animation.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        camera?.start()
    }
    
    /**
     Notifies the view controller that its view is about to be removed from a view hierarchy.
     
     - parameter animated: If `true`, the disappearance of the view is animated.
     */
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera?.stop()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // note that in the mapping left and right are reversed. That's because landscape values have different meanings
        // in UIDeviceOrientation and AVCaptureVideoOrientation. Refer to their documentaion for more info
        let orientationsMapping = [UIDeviceOrientation.portrait: AVCaptureVideoOrientation.portrait,
                                   UIDeviceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeLeft,
                                   UIDeviceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeRight,
                                   UIDeviceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown]
        let orientation = UIDevice.current.orientation
        (previewView.layer as! AVCaptureVideoPreviewLayer).connection.videoOrientation = orientationsMapping[orientation]!
    }
    
    // MARK: Toggle UI elements
    /**
     Show the capture button. Should be called when onboarding is dismissed.
     */
    public func showCaptureButton() {
        guard cameraState == .valid else { return }
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
        guard cameraState == .valid else { return }
        cameraOverlay.alpha = 1
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        cameraOverlay.alpha = 0
    }
    
    // MARK: Image capture
    @objc fileprivate func captureImage(_ sender: AnyObject) {
        guard let camera = camera else {
            if GINIConfiguration.DEBUG {
                // Retrieve image from default image view to make sure image was set and therefor the correct states were checked before.
                if let image = self.defaultImageView?.image,
                   let imageData = UIImageJPEGRepresentation(image, 1) {
                    self.successBlock?(imageData)
                }
            }
            return print("GiniVision: No camera initialized.")
        }
        camera.captureStillImage { inner in
            do {
                var imageData = try inner()
                
                // Set meta information in image
                var manager = GINIMetaInformationManager(imageData: imageData)
                manager.filterMetaInformation()
                if let richImageData = manager.imageData(withCompression: 0.2) {
                    imageData = richImageData
                }
                
                // Call success block
                self.successBlock?(imageData as Data)
            } catch let error as GINICameraError {
                self.errorBlock?(error)
            } catch _ {
                print("GiniVision: An unknown error occured.")
            }
        }
        
    }
    
    // MARK: Focus handling
    fileprivate typealias FocusIndicator = UIImageView
    
    @objc fileprivate func focusAndExposeTap(_ sender: UITapGestureRecognizer) {
        let devicePoint = (previewView.layer as! AVCaptureVideoPreviewLayer).captureDevicePointOfInterest(for: sender.location(in: sender.view))
        camera?.focusWithMode(.autoFocus, exposeWithMode: .autoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
        let imageView = createFocusIndicator(withImage: cameraFocusSmall, atPoint: (previewView.layer as! AVCaptureVideoPreviewLayer).pointForCaptureDevicePoint(ofInterest: devicePoint))
        showFocusIndicator(imageView)
    }
    
    @objc fileprivate func subjectAreaDidChange(_ notification: Notification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        camera?.focusWithMode(.continuousAutoFocus, exposeWithMode: .continuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
        let imageView = createFocusIndicator(withImage: cameraFocusLarge, atPoint: (previewView.layer as! AVCaptureVideoPreviewLayer).pointForCaptureDevicePoint(ofInterest: devicePoint))
        showFocusIndicator(imageView)
    }
    
    fileprivate func createFocusIndicator(withImage image: UIImage?, atPoint point: CGPoint) -> FocusIndicator? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.center = point
        return imageView
    }
    
    fileprivate func showFocusIndicator(_ imageView: FocusIndicator?) {
        guard cameraState == .valid else { return }
        guard let imageView = imageView else { return }
        for subView in self.previewView.subviews {
            if let focusIndicator = subView as? FocusIndicator {
                focusIndicator.removeFromSuperview()
            }
        }
        self.previewView.addSubview(imageView)
        UIView.animate(withDuration: 1.5,
                                   animations: {
                                    imageView.alpha = 0.0
            },
                                   completion: { (success: Bool) -> Void in
                                    imageView.removeFromSuperview()
        })
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Preview view
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        // lower priority constraints - will make the preview "want" to get bigger
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0, priority: 500)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0, priority: 500)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1, constant: 0, priority: 500)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .right, relatedBy: .equal, toItem: superview, attribute: .right, multiplier: 1, constant: 0, priority: 500)
        
        // required constraints - make sure the preview doesn't expand into other views or off-screen
        ConstraintUtils.addActiveConstraint(item: superview!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: previewView, attribute: .bottom, multiplier: 1, constant: 0, priority: 1000)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: superview, attribute: .top, multiplier: 1, constant: 0, priority: 1000)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: superview, attribute: .left, multiplier: 1, constant: 0, priority: 1000)
        ConstraintUtils.addActiveConstraint(item: superview!, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: previewView, attribute: .right, multiplier: 1, constant: 0, priority: 1000)
        
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .width, relatedBy: .equal, toItem: previewView, attribute: .height, multiplier: 3/4, constant: 0)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: previewView, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 0)
        
        // Camera overlay view
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .top, relatedBy: .equal, toItem: previewView, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .trailing, relatedBy: .equal, toItem: previewView, attribute: .trailing, multiplier: 1, constant: -23)
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .bottom, relatedBy: .equal, toItem: previewView, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .leading, relatedBy: .equal, toItem: previewView, attribute: .leading, multiplier: 1, constant: 23)
        
        // Controls view
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .top, relatedBy: .equal, toItem: previewView, attribute: .bottom, multiplier: 1, constant: 0, priority: 750)
        ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: captureButton, attribute: .height, multiplier: 1.1, constant: 0)
        
        // Capture button
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 66)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 66)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .centerX, relatedBy: .equal, toItem: controlsView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .centerY, relatedBy: .equal, toItem: controlsView, attribute: .centerY, multiplier: 1, constant: 0)
    }
    
    fileprivate func addNotAuthorizedView() {
        
        // Add not authorized view
        let view = GINICameraNotAuthorizedView()
        previewView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: previewView, attribute: .width, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: previewView, attribute: .height, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: previewView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: previewView, attribute: .centerY, multiplier: 1, constant: 0)
        
        // Hide camera UI
        hideCameraOverlay()
        hideCaptureButton()
    }
    
    /// Adds a default image to the canvas when no camera is available (DEBUG mode only)
    fileprivate func addDefaultImage() {
        defaultImageView = UIImageView(image: defaultImage)
        guard let defaultImageView = defaultImageView else { return }
        
        defaultImageView.contentMode = .scaleAspectFit
        previewView.addSubview(defaultImageView)
        
        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: defaultImageView, attribute: .width, relatedBy: .equal, toItem: previewView, attribute: .width, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: defaultImageView, attribute: .height, relatedBy: .equal, toItem: previewView, attribute: .height, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: defaultImageView, attribute: .centerX, relatedBy: .equal, toItem: previewView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: defaultImageView, attribute: .centerY, relatedBy: .equal, toItem: previewView, attribute: .centerY, multiplier: 1, constant: 0)
    }
    
}

