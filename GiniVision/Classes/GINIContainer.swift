//
//  GINIContainer.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal protocol GINIContainer {
    
    var containerView: UIView { get }
    var contentController: UIViewController { get }
    
    func displayContent(controller: UIViewController)
    
}

internal extension GINIContainer where Self: UIViewController {
    
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
}