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
 The CameraViewControllerDelegate protocol defines methods that allow you to handle captured images and user
 actions.
 
 - note: Component API only.
 */
@objc public protocol CameraViewControllerDelegate: class {
    /**
     Called when a user takes a picture, imports a PDF/QRCode or imports one or several images.
     Once the method has been implemented, it is necessary to check if the number of
     documents accumulated doesn't exceed the minimun (`GiniImageDocument.maxPagesCount`).
     
     - parameter viewController: `CameraViewController` where the documents were taken.
     - parameter documents: One or several documents either captured or imported in
     the `CameraViewController`. They can contain an error produced in the validation process.
     */
    @objc func camera(_ viewController: CameraViewController,
                      didCapture document: GiniVisionDocument)
    
    /**
     Called when a user selects a picker from the picker selector sheet.
     
     - parameter viewController: `CameraViewController` where the documents were taken.
     - parameter documentPicker: `DocumentPickerType` selected in the sheet.
     */
    @objc func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType)
    
    /**
     Called when the `CameraViewController` appears.
     
     - parameter viewController: Camera view controller that appears.
     */
    @objc func cameraDidAppear(_ viewController: CameraViewController)
    
    /**
     Called when a user taps the `MultipageReviewButton` (the one with the thumbnail of the images(s) taken).
     Once this method is called, the `MultipageReviewViewController` should be presented.
     
     - parameter viewController: Camera view controller where the button was tapped.
     */
    @objc func cameraDidTapMultipageReviewButton(_ viewController: CameraViewController)

}

/**
 Block that will be executed when the camera successfully takes a picture.
 It contains the JPEG representation of the image including meta information about the image.
 
 - note: Component API only.
 */
@available(*, deprecated)
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
@available(*, deprecated)
public typealias CameraErrorBlock = (_ error: CameraError) -> Void

/**
 Block that will be executed if an error occurs on the camera screen.
 
 - note: Component API only.
 */
public typealias CameraScreenFailureBlock = (_ error: GiniVisionError) -> Void

/**
 The `CameraViewController` provides a custom camera screen which enables the user to take a
 photo of a document to be analyzed. The user can focus the camera manually if the auto focus does not work.
  
 - note: Component API only.
 */
//swiftlint:disable file_length

@objcMembers public final class CameraViewController: UIViewController {
    
    /**
     The object that acts as the delegate of the camera view controller.
     */
    public weak var delegate: CameraViewControllerDelegate?
    
    var opaqueView: UIView?
    var toolTipView: ToolTipView?
    let giniConfiguration: GiniConfiguration
    let currentDevice: UIDevice
    fileprivate var detectedQRCodeDocument: GiniQRCodeDocument?
    fileprivate var currentQRCodePopup: QRCodeDetectedPopupView?
    
    lazy var cameraPreviewViewController: CameraPreviewViewController = {
        let cameraPreviewViewController = CameraPreviewViewController()
        cameraPreviewViewController.delegate = self
        return cameraPreviewViewController
    }()
    
    lazy var cameraButtonsViewController: CameraButtonsViewController = {
        let cameraButtonsViewController = CameraButtonsViewController()
        cameraButtonsViewController.delegate = self
        return cameraButtonsViewController
    }()
    
    // Output
    fileprivate var successBlock: CameraScreenSuccessBlock?
    fileprivate var failureBlock: CameraScreenFailureBlock?
    
    /**
     Designated initializer for the `CameraViewController` which allows
     to set the `GiniConfiguration for the camera screen`.
     All the interactions with this screen are handled by `CameraViewControllerDelegate`.
     
     - parameter giniConfiguration: `GiniConfiguration` instance.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
     */
    public init(giniConfiguration: GiniConfiguration, currentDevice: UIDevice = .current) {
        self.giniConfiguration = giniConfiguration
        self.currentDevice = currentDevice
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     Convenience initializer for the `CameraViewController` which allows
     to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when document was picked or image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
     */
    @available(*, deprecated, message: "Use init(giniConfiguration:) initializer instead")
    public convenience init(successBlock: @escaping CameraScreenSuccessBlock,
                            failureBlock: @escaping CameraScreenFailureBlock) {
        self.init(giniConfiguration: GiniConfiguration.shared)
        // Set callback
        self.successBlock = successBlock
        self.failureBlock = failureBlock
        
    }
    
    /**
     Convenience initializer for the `CameraViewController` which allows
     to set a success block and an error block which will be executed accordingly.
     
     - parameter success: Success block to be executed when an image was taken.
     - parameter failure: Error block to be executed if an error occurred.
     
     - returns: A view controller instance allowing the user to take a picture.
     */
    
    @available(*, deprecated, message: "Use init(giniConfiguration:) initializer instead")
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
    
    fileprivate func didPick(_ document: GiniVisionDocument) {
        if let delegate = delegate {
            delegate.camera(self, didCapture: document)
        } else {
            successBlock?(document)
        }
    }
    
    public override func loadView() {
        super.loadView()
        edgesForExtendedLayout = []
        view.backgroundColor = giniConfiguration.backgroundColor
        
        // `previewView` must be added at 0 because otherwise NotAuthorizedView button won't ever be touchable
        addChild(cameraPreviewViewController)
        view.addSubview(cameraPreviewViewController.view)
        cameraPreviewViewController.didMove(toParent: self)
        
        addChild(cameraButtonsViewController)
        view.insertSubview(cameraButtonsViewController.view, aboveSubview: cameraPreviewViewController.view)
        cameraButtonsViewController.didMove(toParent: self)

        addConstraints()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if giniConfiguration.fileImportSupportedTypes != .none {
            cameraButtonsViewController.addFileImportButton()
            if ToolTipView.shouldShowFileImportToolTip {
                createFileImportTip(giniConfiguration: giniConfiguration)
                if !OnboardingContainerViewController.willBeShown {
                    showFileImportTip()
                }
            }
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(to: giniConfiguration.statusBarStyle)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.cameraDidAppear(self)        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.toolTipView?.arrangeViews()
        self.opaqueView?.frame = cameraPreviewViewController.view.frame
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return 
            }
            
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
        cameraButtonsViewController.view.alpha = 1
    }
    
    /**
     Hide the capture button. Should be called when onboarding is presented.
     */
    public func hideCaptureButton() {
        cameraButtonsViewController.view.alpha = 0
    }
    
    /**
     Show the camera overlay. Should be called when onboarding is dismissed.
     */
    public func showCameraOverlay() {
        cameraPreviewViewController.showCameraOverlay()
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        cameraPreviewViewController.hideCameraOverlay()
    }
    
    /**
     Show the fileImportTip. Should be called when onboarding is dismissed.
     */
    public func showFileImportTip() {
        self.toolTipView?.show {
            self.opaqueView?.alpha = 1
            self.cameraButtonsViewController.captureButton.isEnabled = false
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
    
    /**
     Used to animate the captured image, first shrinking it and then translating it to the captured images stack view.
     
     - parameter imageDocument: `GiniImageDocument` to be animated.
     - parameter completion: Completion block.
     
     */
    public func animateToControlsView(imageDocument: GiniImageDocument, completion: (() -> Void)? = nil) {
        guard let documentImage = imageDocument.previewImage else { return }
        let previewImageView = previewCapturedImageView(with: documentImage)
        view.addSubview(previewImageView)
        
        UIView.animate(withDuration: AnimationDuration.medium, animations: {
            previewImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            UIView.animateKeyframes(withDuration: AnimationDuration.medium, delay: 0.6, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    let thumbnailSize = self.cameraButtonsViewController.capturedImagesStackView.thumbnailSize
                    let scaleRatioY = thumbnailSize.height / self.cameraPreviewViewController.view.frame.height
                    let scaleRatioX = thumbnailSize.width / self.cameraPreviewViewController.view.frame.width
                    
                    previewImageView.transform = CGAffineTransform(scaleX: scaleRatioX, y: scaleRatioY)
                    previewImageView.center = self.cameraButtonsViewController.capturedImagesStackView
                        .thumbnailFrameRelative(to: self.view)
                        .center
                })
                if !self.cameraButtonsViewController.capturedImagesStackView.isHidden {
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 1, animations: {
                        previewImageView.alpha = 0
                    })
                }
            }, completion: { _ in
                previewImageView.removeFromSuperview()
                self.cameraButtonsViewController.capturedImagesStackView.addImageToStack(image: documentImage)
                completion?()
            })
        })
    }
    
    /**
     Replaces the captured images stack content with new images.
     
     - parameter images: New images to be shown in the stack. (Last image will be shown on top)
     */
    public func replaceCapturedStackImages(with images: [UIImage]) {
        cameraButtonsViewController.capturedImagesStackView.replaceStackImages(with: images)
        cameraButtonsViewController.rightStackView.layoutIfNeeded()
    }

    fileprivate func showPopup(forQRDetected qrDocument: GiniQRCodeDocument, didTapDone: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            
            let newQRCodePopup = QRCodeDetectedPopupView(parent: self.view,
                                                         refView: self.cameraPreviewViewController.view,
                                                         document: qrDocument,
                                                         giniConfiguration: self.giniConfiguration)
            newQRCodePopup.didTapDone = { [weak self] in
                didTapDone()
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
    
    private func cameraDidCapture(imageData: Data?, error: CameraError?) {
        guard let imageData = imageData,
            error == nil else {
                self.failureBlock?(error ?? .captureFailed)
                return
        }
        
        let imageDocument = GiniImageDocument(data: imageData,
                                              imageSource: .camera,
                                              deviceOrientation: UIApplication.shared.statusBarOrientation)
        didPick(imageDocument)
    }
    
    private func previewCapturedImageView(with image: UIImage) -> UIImageView {
        let imageFrame = cameraPreviewViewController.view.frame
        let imageView = UIImageView(frame: imageFrame)
        imageView.center = cameraPreviewViewController.view.center
        imageView.image = image
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: -2, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.3
        
        return imageView
    }
}

// MARK: - CameraPreviewViewControllerDelegate

extension CameraViewController: CameraPreviewViewControllerDelegate {
    func cameraPreview(_ viewController: CameraPreviewViewController, didDetect qrCodeDocument: GiniQRCodeDocument) {
        if detectedQRCodeDocument != qrCodeDocument {
            detectedQRCodeDocument = qrCodeDocument
            showPopup(forQRDetected: qrCodeDocument) { [weak self] in
                guard let self = self else { return }
                self.didPick(qrCodeDocument)
            }
        }
    }
}

// MARK: - CameraButtonsViewControllerDelegate

extension CameraViewController: CameraButtonsViewControllerDelegate {
    func cameraButtons(_ viewController: CameraButtonsViewController,
                       didTapOn button: CameraButtonsViewController.Button) {
        switch button {
        case .fileImport:
            showImportFileSheet()
        case .capture:
            cameraPreviewViewController.captureImage(completion: cameraDidCapture)
        case .imagesStack:
            delegate?.cameraDidTapMultipageReviewButton(self)
        }
    }
}

// MARK: - Document import

extension CameraViewController {    
    func addValidationLoadingView() -> UIView {
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurredView.alpha = 0
        blurredView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        loadingIndicator.startAnimating()
        blurredView.contentView.addSubview(loadingIndicator)
        self.view.addSubview(blurredView)
        blurredView.frame = self.view.bounds
        loadingIndicator.center = blurredView.center
        UIView.animate(withDuration: AnimationDuration.medium, animations: {
            blurredView.alpha = 1
        })
        
        return blurredView
    }
    
    @objc fileprivate func showImportFileSheet() {
        toolTipView?.dismiss(withCompletion: nil)
        
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var alertViewControllerMessage: String = .localized(resource: CameraStrings.popupTitleImportPDF)
        
        if giniConfiguration.fileImportSupportedTypes == .pdf_and_images {
            alertViewController.addAction(UIAlertAction(title: .localized(resource: CameraStrings.popupOptionPhotos),
                                                        style: .default) { [unowned self] _ in
                self.delegate?.camera(self, didSelect: .gallery)
            })
            alertViewControllerMessage = .localized(resource: CameraStrings.popupTitleImportPDForPhotos)
        }
        
        alertViewController.addAction(UIAlertAction(title: .localized(resource: CameraStrings.popupOptionFiles),
                                                    style: .default) { [unowned self] _ in
            self.delegate?.camera(self, didSelect: .explorer)
        })
        
        alertViewController.addAction(UIAlertAction(title: .localized(resource: CameraStrings.popupCancel),
                                                    style: .cancel, handler: nil))
        
        alertViewController.message = alertViewControllerMessage
        alertViewController.popoverPresentationController?.sourceView = cameraButtonsViewController.fileImportButtonView
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func createFileImportTip(giniConfiguration: GiniConfiguration) {
        opaqueView = OpaqueViewFactory.create(with: giniConfiguration.toolTipOpaqueBackgroundStyle)
        opaqueView?.alpha = 0
        self.view.addSubview(opaqueView!)

        toolTipView = ToolTipView(text: .localized(resource: CameraStrings.fileImportTipLabel),
                                  giniConfiguration: giniConfiguration,
                                  referenceView: cameraButtonsViewController.fileImportButtonView,
                                  superView: self.view,
                                  position: UIDevice.current.isIpad ? .left : .above,
                                  distanceToRefView: UIEdgeInsets(top: 36, left: 0, bottom: 36, right: 0))
        
        toolTipView?.willDismiss = { [weak self] in
            guard let `self` = self else { return }
            self.opaqueView?.removeFromSuperview()
            self.cameraButtonsViewController.captureButton.isEnabled = true
        }
    }
}
