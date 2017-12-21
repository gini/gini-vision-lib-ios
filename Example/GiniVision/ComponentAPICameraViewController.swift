//
//  ComponentAPICameraViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

protocol ComponentAPICameraViewControllerDelegate: class {
    func componentAPICamera(viewController: UIViewController, didPickDocument document: GiniVisionDocument)
    func componentAPICamera(viewController: UIViewController, didTapClose: ())
}

/**
 View controller showing how to implement the camera using the Component API of the Gini Vision Library for iOS.
 */
final class ComponentAPICameraViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    weak var delegate: ComponentAPICameraViewControllerDelegate?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Create the camera view controller
        contentController = CameraViewController(successBlock: { [weak self] document in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.delegate?.componentAPICamera(viewController: self,
                                                      didPickDocument: document)
                }
        }, failureBlock: { error in
            print("Component API camera view controller received error:\n\(error)")
        })
        
        // 3. Display the camera view controller
        displayContent(contentController)
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
        delegate?.componentAPICamera(viewController: self, didTapClose: ())
    }
}

