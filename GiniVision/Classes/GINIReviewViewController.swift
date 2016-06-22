//
//  GINIReviewViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 20/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

public typealias GINIReviewSuccessBlock = (imageData: NSData) -> ()

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
    private var errorBlock: GINIErrorBlock?
    
    public init(_ imageData: NSData, success: GINIReviewSuccessBlock, failure: GINIErrorBlock) {
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
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(scrollView.bounds.size)
    }

    // MARK: Rotation handling
    @IBAction func rotate(sender: AnyObject) {
        // TODO: Implement rotation
        guard let data = UIImageJPEGRepresentation(imageView.image!, 1) else {
            return // TODO: Add error calls
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
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)
    }
    
}

