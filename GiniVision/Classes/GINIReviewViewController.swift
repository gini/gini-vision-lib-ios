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
 The `GINIReviewViewController` provides a custom review screen. The user has the option to check for blurrines and reading direction. If the result is not satisfying, the user either can return to the camera screen or s/he can turn the photo in steps of 90 degrees. The photo should be uploaded to Gini’s backend immediately after haven taken the photo as we assume that in most cases the photo is good enough to be further processed.

 **Text ressources on this screen**
 
 * `ginivision.navigationbar.review.title` (Screen API only.)
 * `ginivision.navigationbar.review.back` (Screen API only.)
 * `ginivision.navigationbar.review.continue` (Screen API only.)
 * `ginivision.review.top`
 * `ginivision.review.bottom`
 
 **Image ressources on this screen**
 
 * `reviewRotateButton`
 * `navigationReviewBack` (Screen API only.)
 * `navigationReviewContinue` (Screen API only.)
 
 Ressources listed also contain ressources for the container view controller. They are marked with _Screen API only_.

 - note: Component API only.
 */
public final class GINIReviewViewController: UIViewController {
    
    // User interface
    private var scrollView = UIScrollView()
    private var imageView = UIImageView()
    
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
     Designated intitializer for the `GINIReviewViewController` which allows to set a success and error block which will be executed accordingly.

     
     - parameter imageData: JPEG representation as a result from the camera or camera roll.
     - parameter success:   Success block to be executed when image was rotated.
     - parameter failure:   Error block to be exectued when an error occured.
     
     - returns: A view controller instance allowing the user to review a picture of a document.
     */
    public init(_ imageData: NSData, success: GINIReviewSuccessBlock, failure: GINIReviewErrorBlock) {
        super.init(nibName: nil, bundle: nil)
        
        // Set callback
        successBlock = success
        errorBlock = failure
        
        // Configure scroll view
        scrollView.delegate = self
        
        // Configure image view
        imageView.image = UIImage(data: imageData)
        
        // Configure colors
        view.backgroundColor = UIColor.clearColor()
        
        // Configure view hierachy
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
                
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

    // MARK: Rotation handling
    @objc private func rotate(sender: AnyObject) {
        // TODO: Implement rotation
        guard let data = UIImageJPEGRepresentation(imageView.image!, 1) else {
            return
        }
        successBlock?(imageData: data)
    }
    
    // MARK: Zoom handling
    private func updateMinZoomScaleForSize(size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
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
        
        view.layoutIfNeeded()
    }
    
}

extension GINIReviewViewController: UIScrollViewDelegate {
    
    /**
     Asks the delegate for the view to scale when zooming is about to occur in the scroll view.
     
     - parameter scrollView: The scroll-view object displaying the content view.
     - returns: A `UIView` object that will be scaled as a result of the zooming gesture.
     */
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    /**
     Tells the delegate that the scroll view’s zoom factor changed.
     
     - parameter scrollView: The scroll-view object whose zoom factor changed.
     */
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
}

