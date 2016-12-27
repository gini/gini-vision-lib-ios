//
//  NoResultViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 22/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

class NoResultViewController: UIViewController {
    
    @IBOutlet var rotateImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rotateImageView.image = rotateImageView.image?.withRenderingMode(.alwaysTemplate)
    }
    
    @IBAction func retry(_ sender: AnyObject) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
}
