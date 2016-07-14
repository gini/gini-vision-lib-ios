//
//  GINIReviewViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 20/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Block which will be executed each time the user rotates a picture. It contains the JPEG representation of the image including meta information about the rotated image.
 
 - note: Component API only.
 */
public typealias GINIReviewSuccessBlock = (imageData: NSData) -> ()

/**
 Block which will be executed when an error occurs on the review screen. It contains a review specific error.
 
 - note: Component API only.
 */
public typealias GINIReviewErrorBlock = (error: GINIReviewError) -> ()

/**
 The `GINIReviewViewController` provides a custom review screen. The user has the option to check for blurriness and document orientation. If the result is not satisfying, the user can either return to the camera screen or rotate the photo by steps of 90 degrees. The photo should be uploaded to Gini’s backend immediately after having been taken as it is safe to assume that in most cases the photo is good enough to be processed further.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.review.title` (Screen API only.)
 * `ginivision.navigationbar.review.back` (Screen API only.)
 * `ginivision.navigationbar.review.continue` (Screen API only.)
 * `ginivision.review.top`
 * `ginivision.review.bottom`
 
 **Image resources for this screen**
 
 * `reviewRotateButton`
 * `navigationReviewBack` (Screen API only.)
 * `navigationReviewContinue` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. They are marked with _Screen API only_.
 
 - note: Component API only.
 */
@objc public final class GINIReviewViewController: UIViewController {
    
    // User interface
    private var scrollView   = UIScrollView()
    private var imageView    = UIImageView()
    private var topView      = UIView()
    private var bottomView   = UIView()
    private var rotateButton = UIButton()
    private var bottomLabel  = UILabel()
    
    // Properties
    private var imageViewBottomConstraint: NSLayoutConstraint!
    private var imageViewLeadingConstraint: NSLayoutConstraint!
    private var imageViewTopConstraint: NSLayoutConstraint!
    private var imageViewTrailingConstraint: NSLayoutConstraint!
    
    // Images
    private var rotateButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "reviewRotateButton")
    }
    
    // Output
    private var successBlock: GINIReviewSuccessBlock?
    private var errorBlock: GINIReviewErrorBlock?
    
    /**
     Designated intitializer for the `GINIReviewViewController` which allows to set a success block and an error block which will be executed accordingly.
     
     
     - parameter imageData: JPEG representation as a result from the camera or camera roll.
     - parameter success:   Success block to be executed when image was rotated.
     - parameter failure:   Error block to be executed if an error occured.
     
     - returns: A view controller instance allowing the user to review a picture of a document.
     */
    public init(_ imageData: NSData, success: GINIReviewSuccessBlock, failure: GINIReviewErrorBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        successBlock = success
        errorBlock = failure
        
        // Configure scroll view
        scrollView.delegate = self
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Configure image view
        imageView.image = UIImage(data: imageData)
        
        // Configure top view
        topView = GININoticeView(text: GINIConfiguration.sharedConfiguration.reviewTextTop)
        
        // Configure rotate button
        rotateButton.setImage(rotateButtonImage, forState: .Normal)
        rotateButton.addTarget(self, action: #selector(rotate), forControlEvents: .TouchUpInside)
        
        // Configure bottom label
        bottomLabel.text = GINIConfiguration.sharedConfiguration.reviewTextBottom
        bottomLabel.numberOfLines = 0
        bottomLabel.textColor = UIColor.whiteColor()
        bottomLabel.textAlignment = .Right
        bottomLabel.adjustsFontSizeToFitWidth = true
        bottomLabel.minimumScaleFactor = 0.7
        bottomLabel.font = GINIConfiguration.sharedConfiguration.reviewTextBottomFont
        
        // Configure view hierachy
        view.addSubview(scrollView)
        view.addSubview(topView)
        view.addSubview(bottomView)
        scrollView.addSubview(imageView)
        bottomView.addSubview(rotateButton)
        bottomView.addSubview(bottomLabel)
        
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
    
    /**
     Called to notify the view controller that its view has just laid out its subviews.
     */
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(scrollView.bounds.size)
    }
    
    /**
     Notifies the view controller that its view was added to a view hierarchy.
     
     - parameter animated: If true, the view was added to the window using an animation.
     */
    public override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            (self.topView as? GININoticeView)?.show()
        }
    }
    
    // MARK: Rotation handling
    @objc private func rotate(sender: AnyObject) {
        // TODO: Implement exif data
        imageView.image = rotateImage(imageView.image)
        guard let data = UIImageJPEGRepresentation(imageView.image!, 1) else {
            return
        }
        successBlock?(imageData: data)
    }
    
    private func rotateImage(image: UIImage?) -> UIImage? {
        guard let cgImage = image?.CGImage else { return nil }
        let rotatedOrientation = nextImageOrientationClockwise(image!.imageOrientation)
        return UIImage(CGImage: cgImage, scale: 1.0, orientation: rotatedOrientation)
    }
    
    private func nextImageOrientationClockwise(orientation: UIImageOrientation) -> UIImageOrientation {
        var nextOrientation: UIImageOrientation!
        switch orientation {
        case .Up, .UpMirrored:
            nextOrientation = .Right
        case .Down, .DownMirrored:
            nextOrientation = .Left
        case .Left, .LeftMirrored:
            nextOrientation = .Up
        case .Right, .RightMirrored:
            nextOrientation = .Down
        }
        return nextOrientation
    }
    
    // MARK: Zoom handling
    @objc private func handleDoubleTap(sender: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    private func updateMinZoomScaleForSize(size: CGSize) {
        guard let image = imageView.image else { return }
        let widthScale = size.width / image.size.width
        let heightScale = size.height / image.size.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    private func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .Width, relatedBy: .Equal, toItem: scrollView, attribute: .Height, multiplier: 3/4, constant: 0)
        
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewTopConstraint = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Top, multiplier: 1, constant: 0)
        imageViewTrailingConstraint = NSLayoutConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: scrollView, attribute: .Trailing, multiplier: 1, constant: 0)
        imageViewBottomConstraint = NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1, constant: 0)
        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: scrollView, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(imageViewTopConstraint)
        UIViewController.addActiveConstraint(imageViewTrailingConstraint)
        UIViewController.addActiveConstraint(imageViewBottomConstraint)
        UIViewController.addActiveConstraint(imageViewLeadingConstraint)
        
        // Top view
        topView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: topView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: topView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: topView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: topView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 35)
        
        // Bottom view
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: bottomView, attribute: .Top, relatedBy: .Equal, toItem: scrollView, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: rotateButton, attribute: .Height, multiplier: 1, constant: 0)
        
        // Rotate button
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .Leading, relatedBy: .Equal, toItem: bottomView, attribute: .Leading, multiplier: 1, constant: 15)
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: 33)
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 33)
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomView, attribute: .CenterY, multiplier: 1, constant: 0)
        
        // Bottom label
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .Trailing, relatedBy: .Equal, toItem: bottomView, attribute: .Trailing, multiplier: 1, constant: -20)
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .Leading, relatedBy: .Equal, toItem: rotateButton, attribute: .Trailing, multiplier: 1, constant: 30, priority: 999)
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 33)
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .CenterY, relatedBy: .Equal, toItem: bottomView, attribute: .CenterY, multiplier: 1, constant: 0)
        
        view.layoutIfNeeded()
    }
    
}

extension GINIReviewViewController: UIScrollViewDelegate {
    
    /**
     Asks the delegate for the view to scale when zooming is about to occur in the scroll view.
     
     - parameter scrollView: The scroll view object displaying the content view.
     - returns: A `UIView` object that will be scaled as a result of the zooming gesture.
     */
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /**
     Informs the delegate that the scroll view’s zoom factor has changed.
     
     - parameter scrollView: The scroll-view object whose zoom factor has changed.
     */
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.updateConstraintsForSize(scrollView.bounds.size)
        }
    }
    
}

