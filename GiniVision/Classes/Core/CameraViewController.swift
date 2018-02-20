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
 Block that will be executed when the camera successfully takes a picture.
 It contains the JPEG representation of the image including meta information about the image.
 
 - note: Component API only.
 */
public typealias CameraSuccessBlock = (_ imageData: Data) -> Void

/**
 Block that will be executed when the camera screen successfully takes a picture or pick a document/picture.
 It contains the JPEG representation of the image including meta information about the image, or the PDF Data.
 It also contains if the document has been imported from camera-roll/document-explorer or from the camera.
 
 - note: Component API only.
 */
public typealias CameraScreenSuccessBlock = (_ document: GiniVisionDocument) -> Void

/**
 Block that will be executed if an error occurs on the camera. It contains a camera specific error.
 
 - note: Component API only.
 */
public typealias CameraErrorBlock = (_ error: CameraError) -> Void

/**
 Block that will be executed if an error occurs on the camera screen.
 
 - note: Component API only.
 */
public typealias CameraScreenFailureBlock = (_ error: GiniVisionError) -> Void

/**
 The `CameraViewController` provides a custom camera screen which enables the user to take a
 photo of a document to be analyzed. The user can focus the camera manually if the auto focus does not work.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.camera.title` (Screen API only.)
 * `ginivision.navigationbar.camera.close` (Screen API only.)
 * `ginivision.navigationbar.camera.help` (Screen API only.)
 * `ginivision.camera.captureButton`
 * `ginivision.camera.notAuthorized`
 * `ginivision.camera.notAuthorizedButton`
 * `ginivision.camera.filepicker.photoLibraryAccessDenied`
 
 **Image resources for this screen**
 
 * `cameraCaptureButton`
 * `cameraFocusLarge`
 * `cameraFocusSmall`
 * `cameraNotAuthorizedIcon`
 * `documentImportButton`
 * `navigationCameraClose` (Screen API only.)
 * `navigationCameraHelp` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. These are marked with _Screen API only_.
 
 - note: Component API only.
 */
//swiftlint:disable file_length

@objc public final class CameraViewController: UIViewController {
    
    fileprivate enum CameraState {
        case valid, notValid
    }
        
    // User interface
    lazy var captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.cameraCaptureButtonImage, for: .normal)
        button.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        button.accessibilityLabel = GiniConfiguration.sharedConfiguration.cameraCaptureButtonTitle
        return button
    }()
    lazy var importFileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.documentImportButtonImage, for: .normal)
        button.addTarget(self, action: #selector(showImportFileSheet), for: .touchUpInside)
        return button
    }()
    lazy var multipageReviewButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 1
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: -2, height: 2)
        button.addTarget(self, action: #selector(multipageReviewButtonAction), for: .touchUpInside)

        return button
    }()
    lazy var reviewContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var reviewBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()
    lazy var previewView: CameraPreviewView = {
        let previewView = CameraPreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        (previewView.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = AVLayerVideoGravityResizeAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
        previewView.addGestureRecognizer(tapGesture)
        return previewView
    }()
    lazy var controlsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    fileprivate var blurEffect: UIVisualEffectView?
    fileprivate var defaultImageView: UIImageView?
    fileprivate var focusIndicatorImageView: UIImageView?
    var toolTipView: ToolTipView?
    fileprivate let interfaceOrientationsMapping: [UIInterfaceOrientation: AVCaptureVideoOrientation] = [
        .portrait: .portrait,
        .landscapeRight: .landscapeRight,
        .landscapeLeft: .landscapeLeft,
        .portraitUpsideDown: .portraitUpsideDown
    ]
    
    // Properties
    fileprivate var camera: Camera?
    fileprivate var cameraState = CameraState.notValid
    fileprivate lazy var filePickerManager: FilePickerManager = {
        return FilePickerManager()
    }()
    fileprivate var detectedQRCodeDocument: GiniQRCodeDocument?
    fileprivate var currentQRCodePopup: QRCodeDetectedPopupView?

    public var didShowCamera: (() -> Void)?
    public var didTapMultipageReviewButton: (() -> Void)?

    // Images
    fileprivate var defaultImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraDefaultDocumentImage")
    }
    fileprivate var cameraCaptureButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButton")
    }
    fileprivate var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    fileprivate var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    fileprivate var documentImportButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "documentImportButton")
    }
    
    // Output
    fileprivate var successBlock: CameraScreenSuccessBlock?
    fileprivate var failureBlock: CameraScreenFailureBlock?
    
    /**
     Designated initializer for the `CameraViewController` which allows
     to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when document was picked or image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
     */
    public init(successBlock: @escaping CameraScreenSuccessBlock,
                failureBlock: @escaping CameraScreenFailureBlock) {

        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        
        self.setupCamera()
    }
    
    /**
     Convenience initializer for the `CameraViewController` which allows
     to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when an image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture.
     */
    
    @available(*, deprecated)
    public convenience init(success: @escaping CameraSuccessBlock, failure: @escaping CameraErrorBlock) {
        self.init(successBlock: { data in
            success(data.data)
        }, failureBlock: { error in
            failure(error as? CameraError ?? .unknown)
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
    
    public override func loadView() {
        super.loadView()
        
        if let validCamera = camera {
            cameraState = .valid
            previewView.session = validCamera.session
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(subjectAreaDidChange),
                                                   name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                   object: camera?.videoDeviceInput?.device)
        }
        
        // `previewView` must be added at 0 because otherwise NotAuthorizedView button won't ever be touchable
        view.insertSubview(previewView, at: 0)
        view.insertSubview(controlsView, aboveSubview: previewView)
        
        previewView.drawGuides(withColor: GiniConfiguration.sharedConfiguration.cameraPreviewCornerGuidesColor)
        controlsView.addSubview(captureButton)
        controlsView.addSubview(reviewContentView)
        reviewContentView.addSubview(multipageReviewButton)
        reviewContentView.insertSubview(reviewBackgroundView,
                                        belowSubview: multipageReviewButton)
        
        // Add constraints
        addConstraints()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePreviewViewOrientation() // Video orientation should be updated once the view has been loaded
        
        if GiniConfiguration.sharedConfiguration.fileImportSupportedTypes != .none {
            enableFileImport()
            if ToolTipView.shouldShowFileImportToolTip {
                createFileImportTip(giniConfiguration: GiniConfiguration.sharedConfiguration)
                if !OnboardingContainerViewController.willBeShown {
                    showFileImportTip()
                }
            }
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didShowCamera?()
    }
    
    /**
     Notifies the view controller that its view is about to be added to a view hierarchy.
     
     - parameter animated: If `true`, the view is added to the window using an animation.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(to: GiniConfiguration.sharedConfiguration.statusBarStyle)
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
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.toolTipView?.arrangeViews()
        self.blurEffect?.frame = previewView.frame
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return 
            }
            
            self.updatePreviewViewOrientation()
            self.toolTipView?.arrangeViews()
            
        })
    }
}

// MARK: - Toggle UI elements

extension CameraViewController {

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
        previewView.guidesLayer?.isHidden = false
        previewView.frameLayer?.isHidden = false
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        previewView.guidesLayer?.isHidden = true
        previewView.frameLayer?.isHidden = true
    }
    
    /**
     Show the fileImportTip. Should be called when onboarding is dismissed.
     */
    public func showFileImportTip() {
        self.toolTipView?.show {
            self.blurEffect?.alpha = 1
            self.captureButton.isEnabled = false
        }
        ToolTipView.shouldShowFileImportToolTip = false
    }
    
    /**
     Hide the fileImportTip. Should be called when onboarding is presented.
     */
    public func hideFileImportTip() {
        self.toolTipView?.alpha = 0
    }
}

// MARK: - Image capture

extension CameraViewController {
    
    fileprivate func setupCamera(giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration) {
        self.camera = Camera(giniConfiguration: giniConfiguration) {[weak self] error in
            if let error = error {
                switch error {
                case .notAuthorizedToUseDevice:
                    addNotAuthorizedView()
                default:
                    if GiniConfiguration.DEBUG { cameraState = .valid; addDefaultImage() }
                }
                self?.failureBlock?(error)
            }
        }
        self.camera?.didDetectQR = {[weak self] qrDocument in
            guard let `self` = self else { return }
            do {
                try qrDocument.validate()
                self.showPopup(forQRDetected: qrDocument)
            } catch {
            }
        }
    }
    
    @objc fileprivate func captureImage(_ sender: AnyObject) {
        guard let camera = camera else {
            return print("GiniVision: No camera initialized.")
        }

        camera.captureStillImage(completion: self.cameraDidCapture)
    }
    
    func cameraDidCapture(imageData: Data?, error: CameraError?) {
        guard let imageData = imageData,
            error == nil else {
                self.failureBlock?(error ?? .captureFailed)
                return
        }
        
        let imageDocument = GiniImageDocument(data: imageData,
                                              imageSource: .camera,
                                              deviceOrientation: UIApplication.shared.statusBarOrientation)
        
        self.animateToControlsView(imageDocument: imageDocument)
        self.successBlock?(imageDocument)
    }
    
    func animateToControlsView(imageDocument: GiniImageDocument) {
        let imageFrame = previewView.frame
        let imageView = UIImageView(frame: imageFrame)
        imageView.center = previewView.center
        imageView.image = imageDocument.previewImage
        
        view.addSubview(imageView)
        
        UIView.animate(withDuration: AnimationDuration.medium, animations: {
            imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            UIView.animate(withDuration: AnimationDuration.slow, delay: 1, animations: {
                let scaleRatioY = self.multipageReviewButton.frame.height / imageFrame.height
                let scaleRatioX = self.multipageReviewButton.frame.width / imageFrame.width

                imageView.transform = CGAffineTransform(scaleX: scaleRatioX, y: scaleRatioY)
                imageView.center = self.reviewContentView.convert(self.multipageReviewButton.center, to: self.view)
            }, completion: { _ in
                imageView.removeFromSuperview()
                self.updateMultipageReviewButton(withImage: imageDocument.previewImage,
                                                 showingStack: self.multipageReviewButton.isUserInteractionEnabled)
            })
        })
    }
    
    @objc fileprivate func multipageReviewButtonAction(_ sender: AnyObject) {
        self.didTapMultipageReviewButton?()
    }
    
    func updateMultipageReviewButton(withImage image: UIImage?, showingStack: Bool) {
        self.reviewBackgroundView.isHidden = !showingStack
        self.multipageReviewButton.setImage(image, for: .normal)
        self.multipageReviewButton.isUserInteractionEnabled = image != nil
    }
    
    func updatePreviewViewOrientation() {
        let orientation: AVCaptureVideoOrientation
        if UIDevice.current.isIpad {
            orientation =  interfaceOrientationsMapping[UIApplication.shared.statusBarOrientation] ?? .portrait
        } else {
            orientation = .portrait
        }
        
        let previewLayer = (self.previewView.layer as? AVCaptureVideoPreviewLayer)
        previewLayer?.connection?.videoOrientation = orientation
    }
    
    fileprivate func showPopup(forQRDetected qrDocument: GiniQRCodeDocument) {
        if self.detectedQRCodeDocument != qrDocument {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.detectedQRCodeDocument = qrDocument
                
                let newQRCodePopup = QRCodeDetectedPopupView(parent: self.view,
                                                             refView: self.previewView,
                                                             document: qrDocument,
                                                             giniConfiguration: GiniConfiguration.sharedConfiguration)
                newQRCodePopup.didTapDone = { [weak self] in
                    self?.successBlock?(qrDocument)
                    self?.detectedQRCodeDocument = nil
                    self?.currentQRCodePopup?.hide()
                }
                
                let didDismiss: () -> Void = { [weak self] in
                    self?.detectedQRCodeDocument = nil
                    self?.currentQRCodePopup = nil
                }

                if self.currentQRCodePopup != nil {
                    self.currentQRCodePopup?.hide { [weak self] in
                        self?.currentQRCodePopup = newQRCodePopup
                        self?.currentQRCodePopup?.show(didDismiss: didDismiss)
                    }
                } else {
                    self.currentQRCodePopup = newQRCodePopup
                    self.currentQRCodePopup?.show(didDismiss: didDismiss)
                }
            }
        }
    }
    
}

// MARK: - Focus handling

extension CameraViewController {
    fileprivate typealias FocusIndicator = UIImageView
    
    @objc fileprivate func focusAndExposeTap(_ sender: UITapGestureRecognizer) {
        guard let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer else { return }
        let devicePoint = previewLayer.captureDevicePointOfInterest(for: sender.location(in: sender.view))
        camera?.focus(withMode: .autoFocus,
                      exposeWithMode: .autoExpose,
                      atDevicePoint: devicePoint,
                      monitorSubjectAreaChange: true)
        let imageView = createFocusIndicator(withImage: cameraFocusSmall,
                                             atPoint: previewLayer.pointForCaptureDevicePoint(ofInterest: devicePoint))
        showFocusIndicator(imageView)
    }
    
    @objc fileprivate func subjectAreaDidChange(_ notification: Notification) {
        guard let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer else { return }
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        
        camera?.focus(withMode: .continuousAutoFocus,
                      exposeWithMode: .continuousAutoExposure,
                      atDevicePoint: devicePoint,
                      monitorSubjectAreaChange: false)
        
        let imageView = createFocusIndicator(withImage: cameraFocusLarge,
                                             atPoint: previewLayer.pointForCaptureDevicePoint(ofInterest: devicePoint))
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
                       completion: { _ in
                        imageView.removeFromSuperview()
        })
    }
}

// MARK: - Document import

extension CameraViewController {
    fileprivate func enableFileImport() {
        // Configure file picker
        filePickerManager.didPickFile = { [unowned self] document in
            self.validateImported(document: document)
        }
        
        // Configure import file button
        controlsView.addSubview(importFileButton)
        addImportButtonConstraints()
        
        if #available(iOS 11.0, *) {
            addDropInteraction()
        }
    }
    
    fileprivate func validateImported(document: GiniVisionDocument) {
        let loadingView = addValidationLoadingView()
        
        DispatchQueue.global().async { [weak self] in
            do {
                try document.validate()
                DispatchQueue.main.async {
                    loadingView.removeFromSuperview()
                    self?.successBlock?(document)
                }
            } catch let error {
                let message: String
                switch error {
                case let validationError as DocumentValidationError:
                    message = validationError.message
                case let customValidationError as CustomDocumentValidationError:
                    message = customValidationError.message
                default:
                    message = DocumentValidationError.unknown.message
                }
                DispatchQueue.main.async {
                    loadingView.removeFromSuperview()
                    self?.showNotValidDocumentError(message: message)
                }
            }
        }
    }
    
    fileprivate func addValidationLoadingView() -> UIView {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurredView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        loadingIndicator.startAnimating()
        blurredView.contentView.addSubview(loadingIndicator)
        self.view.addSubview(blurredView)
        blurredView.frame = self.view.bounds
        loadingIndicator.center = blurredView.center

        return blurredView
    }
    
    @objc fileprivate func showImportFileSheet() {
        toolTipView?.dismiss(withCompletion: nil)
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var alertViewControllerMessage = "PDF importieren"
        
        if GiniConfiguration.sharedConfiguration.fileImportSupportedTypes == .pdf_and_images {
            alertViewController.addAction(UIAlertAction(title: "Fotos", style: .default) { [unowned self] _ in
                self.filePickerManager.showGalleryPicker(from: self, errorHandler: { [unowned self] error in
                    if let error = error as? FilePickerError, error == FilePickerError.photoLibraryAccessDenied {
                        self.showPhotoLibraryPermissionDeniedError()
                    }
                })
            })
            alertViewControllerMessage = "Fotos oder PDF importieren"
        }
        
        alertViewController.addAction(UIAlertAction(title: "Dokumente", style: .default) { [unowned self] _ in
            self.filePickerManager.showDocumentPicker(from: self)
        })
        
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
        
        alertViewController.message = alertViewControllerMessage
        alertViewController.popoverPresentationController?.sourceView = importFileButton
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    @available(iOS 11.0, *)
    fileprivate func addDropInteraction() {
        let dropInteraction = UIDropInteraction(delegate: filePickerManager)
        view.addInteraction(dropInteraction)
    }
    
    fileprivate func createFileImportTip(giniConfiguration: GiniConfiguration) {
        blurEffect = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        blurEffect?.alpha = 0
        self.view.addSubview(blurEffect!)
        
        toolTipView = ToolTipView(text: NSLocalizedString("ginivision.camera.fileImportTip",
                                                          bundle: Bundle(for: GiniVision.self),
                                                          comment: "tooltip text indicating new file import feature"),
                                  textColor: giniConfiguration.fileImportToolTipTextColor,
                                  font: giniConfiguration.customFont.regular.withSize(14),
                                  backgroundColor: giniConfiguration.fileImportToolTipBackgroundColor,
                                  closeButtonColor: giniConfiguration.fileImportToolTipCloseButtonColor,
                                  referenceView: importFileButton,
                                  superView: self.view,
                                  position: UIDevice.current.isIpad ? .left : .above)
        
        toolTipView?.willDismiss = { [weak self] in
            guard let `self` = self else { return }
            self.blurEffect?.removeFromSuperview()
            self.captureButton.isEnabled = true
        }
    }
    
    fileprivate func showPhotoLibraryPermissionDeniedError() {
        let alertMessage = GiniConfiguration.sharedConfiguration.photoLibraryAccessDeniedMessageText
        
        let alertViewController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        alertViewController.addAction(UIAlertAction(title: "Zugriff erteilen", style: .default, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
            UIApplication.shared.openAppSettings()
        }))
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showNotValidDocumentError(message: String) {
        
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        alertViewController.addAction(UIAlertAction(title: "Andere Datei wählen", style: .default, handler: { _ in
            self.showImportFileSheet()
        }))
        
        present(alertViewController, animated: true, completion: nil)
    }
}

// MARK: - Default and not authorized views

extension CameraViewController {
    fileprivate func addNotAuthorizedView() {
        
        // Add not authorized view
        let view = CameraNotAuthorizedView()
        super.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: view, attr: .width, relatedBy: .equal, to: super.view, attr: .width)
        Constraints.active(item: view, attr: .height, relatedBy: .equal, to: super.view, attr: .height)
        Constraints.active(item: view, attr: .centerX, relatedBy: .equal, to: super.view, attr: .centerX)
        Constraints.active(item: view, attr: .centerY, relatedBy: .equal, to: super.view, attr: .centerY)
        
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
        Constraints.active(item: defaultImageView, attr: .width, relatedBy: .equal, to: previewView, attr: .width)
        Constraints.active(item: defaultImageView, attr: .height, relatedBy: .equal, to: previewView, attr: .height)
        Constraints.active(item: defaultImageView, attr: .centerX, relatedBy: .equal, to: previewView, attr: .centerX)
        Constraints.active(item: defaultImageView, attr: .centerY, relatedBy: .equal, to: previewView, attr: .centerY)
    }
}
