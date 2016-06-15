//
//  GINICameraViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 08/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation

public final class GINICameraViewController: UIViewController {
    
    // User interface
    private var controlsView  = UIView()
    private var previewView   = GINICameraPreviewView()
    private var cameraOverlay = UIImageView()
    private var captureButton = UIButton()
    private var focusIndicatorImageView: UIImageView?
    
    // Properties
    private var camera = GINICamera()
    
    // Images
    private var defaultImage: UIImage? {
        return UIImage.preferredClientImage(named: "defaultImage")
    }
    private var captureButtonNormalImage: UIImage? {
        return UIImage.preferredClientImage(named: "cameraCaptureButton")
    }
    private var captureButtonActiveImage: UIImage? {
        return UIImage.preferredClientImage(named: "cameraCaptureButtonActive")
    }
    private var cameraOverlayImage: UIImage? {
        return UIImage.preferredClientImage(named: "cameraOverlay")
    }
    private var cameraFocusSmall: UIImage? {
        return UIImage.preferredClientImage(named: "cameraFocusSmall")
    }
    private var cameraFocusLarge: UIImage? {
        return UIImage.preferredClientImage(named: "cameraFocusLarge")
    }
    
    // Output
    private var imageData: NSData?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        // Configure preview view
        previewView.session = camera.session
        (previewView.layer as! AVCaptureVideoPreviewLayer).videoGravity = AVLayerVideoGravityResizeAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
        previewView.addGestureRecognizer(tapGesture)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(subjectAreaDidChange), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: camera.videoDeviceInput?.device)
        
        // Configure camera overlay
        cameraOverlay.image = cameraOverlayImage
        cameraOverlay.contentMode = .ScaleAspectFit
        
        // Configure capture button
        captureButton.setImage(captureButtonNormalImage, forState: .Normal)
        captureButton.setImage(captureButtonActiveImage, forState: .Highlighted)
        captureButton.addTarget(self, action: #selector(captureImage), forControlEvents: .TouchUpInside)
        
        // Configure colors
        self.view.backgroundColor = UIColor.clearColor()
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
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: View life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        camera.start()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        camera.stop()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if GINIConfiguration.DEBUG {
            if !camera.hasValidInput {
                addDefaultImage()
            }
        }
    }
    
    // MARK: Image capture
    @IBAction func captureImage(sender: AnyObject) {
        camera.captureStillImage { imageData in
            var data = imageData
            
            if GINIConfiguration.DEBUG {
                if data == nil {
                    data = self.defaultImage != nil ? UIImageJPEGRepresentation(self.defaultImage!, 1) : nil
                }
            }
            
            self.imageData = data
        }
    }
    
    // MARK: Focus handling
    @IBAction func focusAndExposeTap(sender: UITapGestureRecognizer) {
        let devicePoint = (previewView.layer as! AVCaptureVideoPreviewLayer).captureDevicePointOfInterestForPoint(sender.locationInView(sender.view))
        camera.focusWithMode(.AutoFocus, exposeWithMode: .AutoExpose, atDevicePoint: devicePoint, monitorSubjectAreaChange: true)
        let imageView = createFocusIndicator(withImage: cameraFocusSmall, atPoint: (previewView.layer as! AVCaptureVideoPreviewLayer).pointForCaptureDevicePointOfInterest(devicePoint))
        showFocusIndicator(imageView)
    }
    
    @objc private func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPointMake(0.5, 0.5)
        camera.focusWithMode(.ContinuousAutoFocus, exposeWithMode: .ContinuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
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
        let defaultImageView = UIImageView(image: defaultImage)
        defaultImageView.contentMode = .ScaleAspectFit
        previewView.addSubview(defaultImageView)
        
        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .Width, relatedBy: .Equal, toItem: previewView, attribute: .Width, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .Height, relatedBy: .Equal, toItem: previewView, attribute: .Height, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .CenterX, relatedBy: .Equal, toItem: previewView, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: defaultImageView, attribute: .CenterY, relatedBy: .Equal, toItem: previewView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
}

