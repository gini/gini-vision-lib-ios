//
//  GINIContainer.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal protocol ContainerViewController {
    
    var containerView: UIView { get }
    var contentController: UIViewController { get }
    
    func displayContent(_ controller: UIViewController)
    
}

internal extension ContainerViewController where Self: UIViewController {
    
    func displayContent(_ controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
}
