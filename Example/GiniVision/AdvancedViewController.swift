//
//  AdvancedViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

class AdvancedViewController: UIViewController {
    
    // Container attributes
    @IBOutlet var containerView: UIView!
    var contentController = GINICameraViewController { (imageData) in
        guard let imageData = imageData else { return }
        print("Advanced example received image data")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        displayContent(contentController)
    }
    
    override func viewDidAppear(animated: Bool) {
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        GINIVision.setConfiguration(giniConfiguration)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayContent(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }

}

