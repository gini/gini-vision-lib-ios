//
//  CameraContainerViewController.swift
//  GiniVision
//
//  Created by Gini on 08/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import GiniVision

class CameraContainerViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    
    private lazy var cameraViewController = GINICameraViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayContentController(cameraViewController)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func displayContentController(content: UIViewController) {
        self.addChildViewController(content)
        content.view.frame = self.containerView.bounds
        self.containerView.addSubview(content.view)
        content.didMoveToParentViewController(self)
    }
}
