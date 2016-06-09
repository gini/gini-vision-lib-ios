//
//  DocumentViewController.swift
//  GiniVision
//
//  Created by Gini on 31/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    
    // User interface
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var rotateButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Input
    var imageData: NSData?
    
    // Output
    var finalImageData: NSData?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
