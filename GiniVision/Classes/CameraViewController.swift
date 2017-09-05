//
//  CameraViewController.swift
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
public typealias CameraSuccessBlock = (_ document: GiniVisionDocument) -> ()

/**
 Block which will be executed if an error occurs on the camera screen. It contains a camera specific error.
 
 - note: Component API only.
 */
public typealias CameraErrorBlock = (_ error: CameraError) -> ()

/**
 The `CameraViewController` provides a custom camera screen which enables the user to take a photo of a document to be analyzed. The user can focus the camera manually if the auto focus does not work.
 
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
 * `cameraOverlay` (Both iPhone and iPad sizes)
 * `cameraNotAuthorizedIcon`
 * `navigationCameraClose` (Screen API only.)
 * `navigationCameraHelp` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. These are marked with _Screen API only_.
 
 - note: Component API only.
 */

@objc public final class CameraViewController: UIViewController {
    
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
    fileprivate var previewView   = CameraPreviewView()
    fileprivate var captureButton = UIButton()
    fileprivate var documentProviderButton = UIButton()
    fileprivate var focusIndicatorImageView: UIImageView?
    fileprivate var defaultImageView: UIImageView?
    fileprivate let interfaceOrientationsMapping = [UIInterfaceOrientation.portrait: AVCaptureVideoOrientation.portrait,
                                                    UIInterfaceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeRight,
                                                    UIInterfaceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeLeft,
                                                    UIInterfaceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown]
    
    // Properties
    fileprivate var camera: Camera?
    fileprivate var cameraState = CameraState.notValid
    fileprivate var filePickerManager: FilePickerManager
    
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
    fileprivate var cameraOverlayImage: UIImage?
    fileprivate var cameraOverlayImageOriented: UIImage? {
        guard let image = cameraOverlayImage, let cgImage = image.cgImage else {
            return nil
        }
        return UIImage(cgImage: cgImage , scale: 1.0, orientation: UIApplication.shared.statusBarOrientation.isLandscape ? .right : UIImageOrientation.up)
    }
    fileprivate var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    fileprivate var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    
    // Output
    fileprivate var successBlock: CameraSuccessBlock?
    fileprivate var errorBlock: CameraErrorBlock?
    
    /**
     Designated intitializer for the `CameraViewController` which allows to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when document was picked or image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture.
     */
    public init(success: @escaping CameraSuccessBlock, failure: @escaping CameraErrorBlock) {
        filePickerManager = FilePickerManager()
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        successBlock = success
        errorBlock = failure
        
        // Configure file picker
        filePickerManager.didPickFile = { [unowned self] document in
            do {
                try document.validate()
                self.successBlock?(document)
            } catch {
                // TODO Handle errors
                print("Invalid file")
            }
        }
        
        // Configure camera
        do {
            camera = try Camera()
        } catch let error as CameraError {
            switch error {
            case .notAuthorizedToUseDevice:
                addNotAuthorizedView()
            default:
                if GiniConfiguration.DEBUG { cameraState = .valid; addDefaultImage() }
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
            (previewView.layer as! AVCaptureVideoPreviewLayer).connection?.videoOrientation = getVideoOrientation()
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
            previewView.addGestureRecognizer(tapGesture)
            NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: camera?.videoDeviceInput?.device)
        }
        
        // Configure capture button
        captureButton.setImage(captureButtonNormalImage, for: .normal)
        captureButton.setImage(captureButtonActiveImage, for: .highlighted)
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        captureButton.accessibilityLabel = GiniConfiguration.sharedConfiguration.cameraCaptureButtonTitle
        
        // Configure document provider button
        documentProviderButton.setTitle("Import", for: .normal)
        documentProviderButton.addTarget(self, action: #selector(importDocument), for: .touchUpInside)
        
        // Configure view hierachy. Must be added at 0 because otherwise NotAuthorizedView button won't ever be touchable
        view.insertSubview(previewView, at: 0)
        view.insertSubview(cameraOverlay, aboveSubview: previewView)
        view.insertSubview(controlsView, aboveSubview: cameraOverlay)
        
        controlsView.addSubview(captureButton)
        controlsView.addSubview(documentProviderButton)
        
        // Add constraints
        addConstraints()
        
        if #available(iOS 11.0, *) {
            addDropInteraction()
        }
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
        
        // Configure camera overlay
        cameraOverlayImage = UIImageNamedPreferred(named: "cameraOverlay")
        cameraOverlay.image = cameraOverlayImageOriented
        cameraOverlay.contentMode = .scaleAspectFit
        
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
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return 
            }
            (self.previewView.layer as? AVCaptureVideoPreviewLayer)?.connection?.videoOrientation = self.getVideoOrientation()

            // Set the cameraOverlayImageOriented to the cameraOverlay. Needed because image can't be scaled to fit the bounds.
            self.cameraOverlay.image = self.cameraOverlayImageOriented
        })
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
            if GiniConfiguration.DEBUG {
                // Retrieve image from default image view to make sure image was set and therefor the correct states were checked before.
                if let image = self.defaultImageView?.image,
                    let imageData = UIImageJPEGRepresentation(image, 0.2) {
                    let imageDocument = GiniImageDocument(data: imageData)
                    self.successBlock?(imageDocument)
                }
            }
            return print("GiniVision: No camera initialized.")
        }
        camera.captureStillImage { inner in
            do {
                var imageData = try inner()
                
                // Set meta information in image
                let manager = ImageMetaInformationManager(imageData: imageData, deviceOrientation: UIApplication.shared.statusBarOrientation)
                manager.filterMetaInformation()
                if let richImageData = manager.imageData() {
                    imageData = richImageData
                }
                let imageDocument = GiniImageDocument(data: imageData)
                
                // Call success block
                self.successBlock?(imageDocument)
            } catch let error as CameraError {
                self.errorBlock?(error)
            } catch _ {
                print("GiniVision: An unknown error occured.")
            }
        }
        
    }
    
    fileprivate func getVideoOrientation() -> AVCaptureVideoOrientation {
        if UIDevice.current.isIpad {
            return interfaceOrientationsMapping[UIApplication.shared.statusBarOrientation] ?? .portrait
        }
        return .portrait
    }
    
    // MARK: Document import
    @objc fileprivate func importDocument(_ sender: AnyObject) {
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertViewController.addAction(UIAlertAction(title: "Photos", style: .default) { [unowned self] _ in
            self.filePickerManager.showGalleryPicker(from: self)
        })
        
        alertViewController.addAction(UIAlertAction(title: "Documents", style: .default) { [unowned self] _ in
            self.filePickerManager.showDocumentPicker(from: self)
        })
        
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        alertViewController.popoverPresentationController?.sourceView = documentProviderButton
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    fileprivate func addDropInteraction() {
        let dropInteraction = UIDropInteraction(delegate: filePickerManager)
        view.addInteraction(dropInteraction)
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
        addPreviewViewConstraints()
        addCameraOverlayConstraints()
        addControlsViewConstraints()
        addControlsViewButtonsConstraints()
    }
    
    fileprivate func addPreviewViewConstraints() {
        previewView.translatesAutoresizingMaskIntoConstraints = false
        
        if UIDevice.current.isIpad {
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .trailing, relatedBy: .equal, toItem: controlsView, attribute: .leading, multiplier: 1, constant: 0, priority: 750)
        } else {
            // lower priority constraints - will make the preview "want" to get bigger
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0, priority: 1000)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0, priority: 750)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0, priority: 750)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0, priority: 750)
            
            // required constraints - make sure the preview doesn't expand into other views or off-screen
            ConstraintUtils.addActiveConstraint(item: self.view!, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: previewView, attribute: .bottom, multiplier: 1, constant: 0, priority: 1000)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .left, multiplier: 1, constant: 0, priority: 1000)
            ConstraintUtils.addActiveConstraint(item: self.view!, attribute: .right, relatedBy: .greaterThanOrEqual, toItem: previewView, attribute: .right, multiplier: 1, constant: 0, priority: 1000)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .width, relatedBy: .equal, toItem: previewView, attribute: .height, multiplier: 3/4, constant: 0)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        }
    }
    
    fileprivate func addControlsViewConstraints() {
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        
        if UIDevice.current.isIpad {
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .leading, relatedBy: .equal, toItem: previewView, attribute: .trailing, multiplier: 1, constant: 0, priority:750)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .width, relatedBy: .equal, toItem: captureButton, attribute: .width, multiplier: 1.3, constant: 0)
        } else {
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .top, relatedBy: .equal, toItem: previewView, attribute: .bottom, multiplier: 1, constant: 0, priority: 750)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: captureButton, attribute: .height, multiplier: 1.1, constant: 0)
        }
    }
    
    fileprivate func addCameraOverlayConstraints() {
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        // All constraints here have a priority less than required to make sure they don't get broken
        // when the view gets too small
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .top, relatedBy: .equal, toItem: previewView, attribute: .top, multiplier: 1, constant: 23, priority: 999)
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .trailing, relatedBy: .equal, toItem: previewView, attribute: .trailing, multiplier: 1, constant: -23, priority: 999)
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .bottom, relatedBy: .equal, toItem: previewView, attribute: .bottom, multiplier: 1, constant: -23, priority: 999)
        ConstraintUtils.addActiveConstraint(item: cameraOverlay, attribute: .leading, relatedBy: .equal, toItem: previewView, attribute: .leading, multiplier: 1, constant: 23, priority: 999)
    }
    
    fileprivate func addControlsViewButtonsConstraints() {
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 66)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 66)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .centerX, relatedBy: .equal, toItem: controlsView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .centerY, relatedBy: .equal, toItem: controlsView, attribute: .centerY, multiplier: 1, constant: 0)
        
        
        // Capture button
        documentProviderButton.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.isIpad {
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .trailing, relatedBy: .equal, toItem: controlsView, attribute: .trailing, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .leading, relatedBy: .equal, toItem: controlsView, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .top, relatedBy: .equal, toItem: captureButton, attribute: .bottom, multiplier: 1, constant: 16)
        } else {
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .top, relatedBy: .equal, toItem: controlsView, attribute: .top, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .leading, relatedBy: .equal, toItem: controlsView, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: documentProviderButton, attribute: .trailing, relatedBy: .equal, toItem: captureButton, attribute: .leading, multiplier: 1, constant: 0, priority: 750)
        }
    }
    
    // MARK: - Default and not authorized views
    
    fileprivate func addNotAuthorizedView() {
        
        // Add not authorized view
        let view = CameraNotAuthorizedView()
        super.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: super.view, attribute: .width, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: super.view, attribute: .height, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: super.view, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: super.view, attribute: .centerY, multiplier: 1, constant: 0)
        
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

