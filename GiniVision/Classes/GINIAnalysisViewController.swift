//
//  GINIAnalysisViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

public final class GINIAnalysisViewController: UIViewController {
    
    // User interface
    private var imageView = UIImageView()
    private var loadingIndicatorView = UIActivityIndicatorView()
    
    public init(_ imageData: NSData) {
        super.init(nibName: nil, bundle: nil)
        
        // Configure image view
        imageView.image = UIImage(data: imageData)
        imageView.contentMode = .ScaleAspectFit
        
        // Configure loading indicator view
        loadingIndicatorView.color = GINIConfiguration.sharedConfiguration.analysisLoadingIndicatorColor
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.activityIndicatorViewStyle = .WhiteLarge
        loadingIndicatorView.startAnimating()
        
        // Configure colors
        view.backgroundColor = UIColor.clearColor()
        
        // Configure view hierachy
        view.addSubview(imageView)
        view.addSubview(loadingIndicatorView)
        
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
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view

        // Image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0, priority: 750)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 3/4, constant: 0)
        
        
        // Loading indicator view
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: loadingIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: imageView, attribute: .CenterX, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: loadingIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: imageView, attribute: .CenterY, multiplier: 1, constant: 0)
    }
    
}
