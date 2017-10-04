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
 Block that will be executed when the camera successfully takes a picture. It contains the JPEG representation of the image including meta information about the image.
 
 - note: Component API only.
 */
public typealias CameraSuccessBlock = (_ imageData: Data) -> ()

/**
 Block that will be executed when the camera screen successfully takes a picture or pick a document/picture. It contains the JPEG representation of the image including meta information about the image, or the PDF Data. It also contains if the document has been imported from camera-roll/document-explorer or from the camera.
 
 - note: Component API only.
 */
public typealias CameraScreenSuccessBlock = (_ document: GiniVisionDocument, _ isImported:Bool) -> ()

/**
 Block that will be executed if an error occurs on the camera. It contains a camera specific error.
 
 - note: Component API only.
 */
public typealias CameraErrorBlock = (_ error: CameraError) -> ()

/**
 Block that will be executed if an error occurs on the camera screen.
 
 - note: Component API only.
 */
public typealias CameraScreenFailureBlock = (_ error: GiniVisionError) -> ()


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
 * `cameraFocusLarge`
 * `cameraFocusSmall`
 * `cameraNotAuthorizedIcon`
 * `navigationCameraClose` (Screen API only.)
 * `navigationCameraHelp` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. These are marked with _Screen API only_.
 
 - note: Component API only.
 */

@objc public final class CameraViewController: UIViewController {
    
    fileprivate enum CameraState {
        case valid, notValid
    }
    
    // User interface
    fileprivate var controlsView  = UIView()
    fileprivate var previewView   = CameraPreviewView()
    fileprivate var captureButton = UIButton()
    fileprivate var focusIndicatorImageView: UIImageView?
    fileprivate var defaultImageView: UIImageView?
    fileprivate lazy var importFileButton = UIButton()
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
    
    fileprivate var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    fileprivate var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    
    // Output
    fileprivate var successBlock: CameraScreenSuccessBlock?
    fileprivate var failureBlock: CameraScreenFailureBlock?
    
    /**
     Designated initializer for the `CameraViewController` which allows to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when document was picked or image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
     */
    public init(successBlock: @escaping CameraScreenSuccessBlock, failureBlock: @escaping CameraScreenFailureBlock) {
        filePickerManager = FilePickerManager()
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        
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
            failureBlock(error)
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
        captureButton.tintColor = .white
        captureButton.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        captureButton.accessibilityLabel = GiniConfiguration.sharedConfiguration.cameraCaptureButtonTitle
        
        // Configure view hierachy. Must be added at 0 because otherwise NotAuthorizedView button won't ever be touchable
        view.insertSubview(previewView, at: 0)
        view.insertSubview(controlsView, aboveSubview: previewView)
        
        previewView.drawGuides(withColor: GiniConfiguration.sharedConfiguration.cameraPreviewCornerGuidesColor)
        controlsView.addSubview(captureButton)
        
        // Add constraints
        addConstraints()
        
        if GiniConfiguration.sharedConfiguration.fileImportSupportedTypes != .none {
            enableFileImport()
        }
    }
    
    /**
     Convenience initializer for the `CameraViewController` which allows to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when an image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture.
     */
    
    @nonobjc
    @available(*, deprecated)
    public convenience init(success: @escaping CameraSuccessBlock, failure: @escaping CameraErrorBlock) {
        self.init(successBlock: { data, _ in
            success(data.data)
        }, failureBlock: { error in
            failure(error as! CameraError)
        })
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
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return 
            }
            (self.previewView.layer as? AVCaptureVideoPreviewLayer)?.connection?.videoOrientation = self.getVideoOrientation()
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
        previewView.areGuides(hidden: false)
        previewView.isFrame(hidden: false)
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        previewView.areGuides(hidden: true)
        previewView.isFrame(hidden: true)
    }
    
    // MARK: Image capture
    @objc fileprivate func captureImage(_ sender: AnyObject) {
        guard let camera = camera else {
            if GiniConfiguration.DEBUG {
                // Retrieve image from default image view to make sure image was set and therefor the correct states were checked before.
                if let image = self.defaultImageView?.image,
                    let imageData = UIImageJPEGRepresentation(image, 0.2) {
                    let imageDocument = GiniImageDocument(data: imageData, imageSource: .camera)
                    self.successBlock?(imageDocument, false)
                }
            }
            return print("GiniVision: No camera initialized.")
        }
        camera.captureStillImage { inner in
            do {
                let imageData = try inner()
                let imageDocument = GiniImageDocument(data: imageData, imageSource: .camera, deviceOrientation: UIApplication.shared.statusBarOrientation)
                
                // Call success block
                self.successBlock?(imageDocument, false)
            } catch let error as CameraError {
                self.failureBlock?(error)
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
    fileprivate func enableFileImport() {
        // Configure file picker
        filePickerManager.didPickFile = { [unowned self] document in
            do {
                try document.validate()
                self.successBlock?(document, true)
            } catch let error as DocumentValidationError {
                self.failureBlock!(error)
            } catch _ {
                self.failureBlock!(DocumentValidationError.unknown)
            }
        }
        
        // Configure import file button
        importFileButton.setImage(UIImageNamedPreferred(named: "documentImportButton"), for: .normal)
        importFileButton.tintColor = .white
        importFileButton.addTarget(self, action: #selector(importDocument), for: .touchUpInside)
        controlsView.addSubview(importFileButton)
        addImportButtonConstraints()
        
        if #available(iOS 11.0, *) {
            addDropInteraction()
        }
    }
    
    @objc fileprivate func importDocument(_ sender: AnyObject) {
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var alertViewControllerMessage = "Dokumente importieren"
        
        if GiniConfiguration.sharedConfiguration.fileImportSupportedTypes == .pdf_and_images {
            alertViewController.addAction(UIAlertAction(title: "Photos", style: .default) { [unowned self] _ in
                self.filePickerManager.showGalleryPicker(from: self, errorHandler: { [unowned self] error in
                    if let error = error as? FilePickerError, error == FilePickerError.photoLibraryAccessDenied {
                        self.showPhotoLibraryPermissionDeniedError()
                    }
                })
            })
            alertViewControllerMessage = "Fotos oder Dokumente importieren"
        }

        alertViewController.addAction(UIAlertAction(title: "Dokumente", style: .default) { [unowned self] _ in
            self.filePickerManager.showDocumentPicker(from: self)
        })
        
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        alertViewController.message = alertViewControllerMessage
        alertViewController.popoverPresentationController?.sourceView = importFileButton
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    fileprivate func addDropInteraction() {
        let dropInteraction = UIDropInteraction(delegate: filePickerManager)
        view.addInteraction(dropInteraction)
    }
    
    
    // MARK: Photo library permission denied error
    fileprivate func showPhotoLibraryPermissionDeniedError() {
        let alertMessage = GiniConfiguration.sharedConfiguration.photoLibraryAccessDeniedMessageText
        
        let alertViewController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        alertViewController.addAction(UIAlertAction(title: "Zugriff erteilen", style: .default, handler: {_ in
            alertViewController.dismiss(animated: true, completion: nil)
            UIApplication.shared.openAppSettings()
        }))
        
        self.present(alertViewController, animated: true, completion: nil)
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
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: previewView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
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
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .top, relatedBy: .equal, toItem: previewView, attribute: .bottom, multiplier: 1, constant: 0, priority:750)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: controlsView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        }
    }

    fileprivate func addControlsViewButtonsConstraints() {
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 70)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 70)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .centerX, relatedBy: .equal, toItem: controlsView, attribute: .centerX, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .centerY, relatedBy: .equal, toItem: controlsView, attribute: .centerY, multiplier: 1, constant: 0)
    }
    
    fileprivate func addImportButtonConstraints() {
        importFileButton.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.isIpad {
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .trailing, relatedBy: .equal, toItem: controlsView, attribute: .trailing, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .leading, relatedBy: .equal, toItem: controlsView, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .top, relatedBy: .equal, toItem: captureButton, attribute: .bottom, multiplier: 1, constant: 60)
        } else {
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .top, relatedBy: .equal, toItem: controlsView, attribute: .top, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .leading, relatedBy: .equal, toItem: controlsView, attribute: .leading, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: importFileButton, attribute: .trailing, relatedBy: .equal, toItem: captureButton, attribute: .leading, multiplier: 1, constant: 0, priority: 750)
            ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .top, relatedBy: .equal, toItem: controlsView, attribute: .top, multiplier: 1, constant: 16)
            ConstraintUtils.addActiveConstraint(item: captureButton, attribute: .bottom, relatedBy: .equal, toItem: controlsView, attribute: .bottom, multiplier: 1, constant: -16)
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

