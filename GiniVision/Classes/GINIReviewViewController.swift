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
public typealias GINIReviewSuccessBlock = (_ imageData: Data) -> ()

/**
 Block which will be executed when an error occurs on the review screen. It contains a review specific error.
 
 - note: Component API only.
 */
public typealias GINIReviewErrorBlock = (_ error: GINIReviewError) -> ()

/**
 The `GINIReviewViewController` provides a custom review screen. The user has the option to check for blurriness and document orientation. If the result is not satisfying, the user can either return to the camera screen or rotate the photo by steps of 90 degrees. The photo should be uploaded to Gini’s backend immediately after having been taken as it is safe to assume that in most cases the photo is good enough to be processed further.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.review.title` (Screen API only.)
 * `ginivision.navigationbar.review.back` (Screen API only.)
 * `ginivision.navigationbar.review.continue` (Screen API only.)
 * `ginivision.review.top`
 * `ginivision.review.rotateButton`
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
    fileprivate var scrollView   = UIScrollView()
    fileprivate var imageView    = UIImageView()
    fileprivate var topView      = UIView()
    fileprivate var bottomView   = UIView()
    fileprivate var rotateButton = UIButton()
    fileprivate var bottomLabel  = UILabel()
    
    // Properties
    fileprivate var imageViewBottomConstraint: NSLayoutConstraint!
    fileprivate var imageViewLeadingConstraint: NSLayoutConstraint!
    fileprivate var imageViewTopConstraint: NSLayoutConstraint!
    fileprivate var imageViewTrailingConstraint: NSLayoutConstraint!
    fileprivate var metaInformationManager: GINIMetaInformationManager?
    
    // Images
    fileprivate var rotateButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "reviewRotateButton")
    }
    
    // Output
    fileprivate var successBlock: GINIReviewSuccessBlock?
    fileprivate var errorBlock: GINIReviewErrorBlock?
    
    /**
     Designated intitializer for the `GINIReviewViewController` which allows to set a success block and an error block which will be executed accordingly.
     
     
     - parameter imageData: JPEG representation as a result from the camera or camera roll.
     - parameter success:   Success block to be executed when image was rotated.
     - parameter failure:   Error block to be executed if an error occured.
     
     - returns: A view controller instance allowing the user to review a picture of a document.
     */
    public init(_ imageData: Data, success: @escaping GINIReviewSuccessBlock, failure: @escaping GINIReviewErrorBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        successBlock = success
        errorBlock = failure
        
        // Set meta information manager
        metaInformationManager = GINIMetaInformationManager(imageData: imageData)
        
        // Configure scroll view
        scrollView.delegate = self
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        // Configure image view
        imageView.image = UIImage(data: imageData)
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityLabel = GINIConfiguration.sharedConfiguration.reviewDocumentImageTitle
        
        // Configure top view
        topView = GININoticeView(text: GINIConfiguration.sharedConfiguration.reviewTextTop)
        
        // Configure bottom view
        bottomView.backgroundColor = GINIConfiguration.sharedConfiguration.reviewBottomViewBackgroundColor.withAlphaComponent(0.8)
        
        // Configure rotate button
        rotateButton.setImage(rotateButtonImage, for: UIControlState())
        rotateButton.addTarget(self, action: #selector(rotate), for: .touchUpInside)
        rotateButton.accessibilityLabel = GINIConfiguration.sharedConfiguration.reviewRotateButtonTitle
        
        // Configure bottom label
        bottomLabel.text = GINIConfiguration.sharedConfiguration.reviewTextBottom
        bottomLabel.numberOfLines = 0
        bottomLabel.textColor = GINIConfiguration.sharedConfiguration.reviewTextBottomColor
        bottomLabel.textAlignment = .right
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
    public override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            (self.topView as? GININoticeView)?.show()
        }
    }
    
    // MARK: Rotation handling
    @objc fileprivate func rotate(_ sender: AnyObject) {
        guard let rotatedImage = rotateImage(imageView.image) else { return }
        imageView.image = rotatedImage
        guard var metaInformationManager = metaInformationManager else { return }
        metaInformationManager.update(imageOrientation: rotatedImage.imageOrientation)
        guard let data = metaInformationManager.imageData() else { return }
        successBlock?(data as Data)
    }
    
    fileprivate func rotateImage(_ image: UIImage?) -> UIImage? {
        guard let cgImage = image?.cgImage else { return nil }
        let rotatedOrientation = nextImageOrientationClockwise(image!.imageOrientation)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: rotatedOrientation)
    }
    
    fileprivate func nextImageOrientationClockwise(_ orientation: UIImageOrientation) -> UIImageOrientation {
        var nextOrientation: UIImageOrientation!
        switch orientation {
        case .up, .upMirrored:
            nextOrientation = .right
        case .down, .downMirrored:
            nextOrientation = .left
        case .left, .leftMirrored:
            nextOrientation = .up
        case .right, .rightMirrored:
            nextOrientation = .down
        }
        return nextOrientation
    }
    
    // MARK: Zoom handling
    @objc fileprivate func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        guard let image = imageView.image else { return }
        let widthScale = size.width / image.size.width
        let heightScale = size.height / image.size.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        
        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageViewTopConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        imageViewTrailingConstraint = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
        imageViewBottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        imageViewLeadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(imageViewTopConstraint)
        UIViewController.addActiveConstraint(imageViewTrailingConstraint)
        UIViewController.addActiveConstraint(imageViewBottomConstraint)
        UIViewController.addActiveConstraint(imageViewLeadingConstraint)
        
        // Top view
        topView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: topView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: topView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: topView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: topView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 35)
        
        // Bottom view
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: bottomView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: bottomView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: rotateButton, attribute: .height, multiplier: 1, constant: 0)
        
        // Rotate button
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .leading, relatedBy: .equal, toItem: bottomView, attribute: .leading, multiplier: 1, constant: 15)
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 33)
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 33)
        UIViewController.addActiveConstraint(item: rotateButton, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0)
        
        // Bottom label
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .trailing, multiplier: 1, constant: -20)
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .leading, relatedBy: .equal, toItem: rotateButton, attribute: .trailing, multiplier: 1, constant: 30, priority: 999)
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 33)
        UIViewController.addActiveConstraint(item: bottomLabel, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.layoutIfNeeded()
    }
    
}

extension GINIReviewViewController: UIScrollViewDelegate {
    
    /**
     Asks the delegate for the view to scale when zooming is about to occur in the scroll view.
     
     - parameter scrollView: The scroll view object displaying the content view.
     - returns: A `UIView` object that will be scaled as a result of the zooming gesture.
     */
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /**
     Informs the delegate that the scroll view’s zoom factor has changed.
     
     - parameter scrollView: The scroll-view object whose zoom factor has changed.
     */
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { 
            self.updateConstraintsForSize(scrollView.bounds.size)
        }
    }
    
}

