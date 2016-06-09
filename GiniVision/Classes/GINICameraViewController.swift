//
//  GINICameraViewController.swift
//  GiniVision
//
//  Created by Gini on 08/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public class GINICameraViewController: UIViewController {
    
    // User interface
    private var controlsView  = UIView()
    private var previewView   = UIView()
    private var cameraOverlay = UIImageView()
    private var captureButton = UIButton()
    
    // Properties
    private var camera: AnyObject? {
        return nil
    }
    
    // Images
    private var defaultImage: UIImage? {
        return UIImage(named: "defaultImage")
    }
    private var captureButtonNormalImage: UIImage? {
        return UIImage(named: "cameraCaptureButton")
    }
    private var captureButtonActiveImage: UIImage? {
        return UIImage(named: "cameraCaptureButtonActive")
    }
    private var cameraOverlayImage: UIImage? {
        return UIImage(named: "cameraOverlay")
    }
    
    
    // Output
    private var imageData: NSData?
    
    // MARK: View life cycle
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        cameraOverlay.image = cameraOverlayImage
        cameraOverlay.contentMode = .ScaleAspectFit
        
        captureButton.setImage(captureButtonNormalImage, forState: .Normal)
        captureButton.setImage(captureButtonActiveImage, forState: .Highlighted)
        captureButton.addTarget(self, action: #selector(captureImage), forControlEvents: .TouchUpInside)
        
        self.view.backgroundColor = UIColor.blackColor()
        previewView.backgroundColor = UIColor.clearColor()
        controlsView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        captureButton.backgroundColor = UIColor.clearColor()
        cameraOverlay.backgroundColor = UIColor.clearColor()
        
        view.addSubview(previewView)
        view.addSubview(cameraOverlay)
        view.addSubview(controlsView)
        controlsView.addSubview(captureButton)
        addConstraints()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if camera == nil {
            addDefaultImage()
        }
    }
    
    @IBAction func captureImage(sender: AnyObject) {
        var data: NSData?
        if camera == nil {
            data = defaultImage != nil ? UIImageJPEGRepresentation(defaultImage!, 1) : nil
        }
        imageData = data
    }
    
    // MARK: Private methods
    private func addConstraints() {
        let superview = self.view
        
        // Preview view
        previewView.translatesAutoresizingMaskIntoConstraints = false
        addActiveConstraint(item: previewView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        addActiveConstraint(item: previewView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        addActiveConstraint(item: previewView, attribute: .Width, relatedBy: .Equal, toItem: previewView, attribute: .Height, multiplier: 3/4, constant: 0)
        addActiveConstraint(item: previewView, attribute: .Width, relatedBy: .Equal, toItem: superview, attribute: .Width, multiplier: 1, constant: 0, priority: 750)
        addActiveConstraint(item: previewView, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: superview, attribute: .Width, multiplier: 1, constant: 0)
        addActiveConstraint(item: previewView, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1, constant: 0)
        
        // Camera overlay view
        cameraOverlay.translatesAutoresizingMaskIntoConstraints = false
        addActiveConstraint(item: cameraOverlay, attribute: .Top, relatedBy: .Equal, toItem: previewView, attribute: .Top, multiplier: 1, constant: 0)
        addActiveConstraint(item: cameraOverlay, attribute: .Trailing, relatedBy: .Equal, toItem: previewView, attribute: .Trailing, multiplier: 1, constant: -23)
        addActiveConstraint(item: cameraOverlay, attribute: .Bottom, relatedBy: .Equal, toItem: previewView, attribute: .Bottom, multiplier: 1, constant: 0)
        addActiveConstraint(item: cameraOverlay, attribute: .Leading, relatedBy: .Equal, toItem: previewView, attribute: .Leading, multiplier: 1, constant: 23)
        
        // Controls view
        controlsView.translatesAutoresizingMaskIntoConstraints = false
        addActiveConstraint(item: controlsView, attribute: .Top, relatedBy: .Equal, toItem: previewView, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        addActiveConstraint(item: controlsView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        addActiveConstraint(item: controlsView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        addActiveConstraint(item: controlsView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        addActiveConstraint(item: controlsView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: captureButton, attribute: .Height, multiplier: 1.1, constant: 0)
        
        // Capture button
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        addActiveConstraint(item: captureButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 55)
        addActiveConstraint(item: captureButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 55)
        addActiveConstraint(item: captureButton, attribute: .CenterX, relatedBy: .Equal, toItem: controlsView, attribute: .CenterX, multiplier: 1, constant: 0)
        addActiveConstraint(item: captureButton, attribute: .CenterY, relatedBy: .Equal, toItem: controlsView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
    private func addDefaultImage() {
        let defaultImageView = UIImageView(image: defaultImage)
        defaultImageView.contentMode = .ScaleAspectFit
        previewView.addSubview(defaultImageView)
        
        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        addActiveConstraint(item: defaultImageView, attribute: .Width, relatedBy: .Equal, toItem: previewView, attribute: .Width, multiplier: 1, constant: 0)
        addActiveConstraint(item: defaultImageView, attribute: .Height, relatedBy: .Equal, toItem: previewView, attribute: .Height, multiplier: 1, constant: 0)
        addActiveConstraint(item: defaultImageView, attribute: .CenterX, relatedBy: .Equal, toItem: previewView, attribute: .CenterX, multiplier: 1, constant: 0)
        addActiveConstraint(item: defaultImageView, attribute: .CenterY, relatedBy: .Equal, toItem: previewView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
    private func addActiveConstraint(item view1: AnyObject, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: AnyObject?, attribute attr2: NSLayoutAttribute, multiplier: CGFloat, constant c: CGFloat, priority: UILayoutPriority = 1000) {
        let constraint = NSLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        constraint.priority = priority
        constraint.active = true
    }
}

