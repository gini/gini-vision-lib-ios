//
//  CameraContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 08/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class GINICameraContainerViewController: UIViewController, GINIContainer {
    
    // Container attributes
    internal var containerView = UIView()
    internal var contentController: UIViewController = GINICameraViewController()
    
    // Output
    private var imageData: NSData?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // TODO: Make title configurable
        title = GINIConfiguration.sharedConfiguration.navigationBarTitleCamera
                
        // Configure colors
        view.backgroundColor = GINIConfiguration.sharedConfiguration.backgroundColor
        
        // Configure view hierachy
        view.addSubview(containerView)
        
        // Add constraints
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayContent(contentController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Constraints
    private func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        UIViewController.addActiveConstraint(item: containerView, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1, constant: 0)
        UIViewController.addActiveConstraint(item: containerView, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1, constant: 0)
    }

}
