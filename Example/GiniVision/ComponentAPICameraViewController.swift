//
//  ComponentAPICameraViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

protocol ComponentAPICameraScreenDelegate:class {
    func didPick(document:GiniVisionDocument)
    func didTapClose()
}

/**
 View controller showing how to implement the camera using the Component API of the Gini Vision Library for iOS.
 */
class ComponentAPICameraViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    weak var delegate:ComponentAPICameraScreenDelegate?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Create the camera view controller
        contentController = CameraViewController(successBlock:
            { document in
                DispatchQueue.main.async {
                    self.delegate?.didPick(document: document)
                }
        }, failureBlock: { error in
            print("Component API camera view controller received error:\n\(error)")
        })
        
        // 3. Display the camera view controller
        displayContent(contentController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // Displays the content controller inside the container view
    func displayContent(_ controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    // MARK: User actions
    @IBAction func back(_ sender: AnyObject) {
        delegate?.didTapClose()
    }
}

