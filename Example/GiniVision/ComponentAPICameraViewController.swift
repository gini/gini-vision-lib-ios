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
    func componentAPICamera(_ viewController: UIViewController, didPickDocument document: GiniVisionDocument)
    func componentAPICamera(_ viewController: UIViewController, didTapClose: ())
    func componentAPICamera(_ viewController: UIViewController, didSelect documentPicker: DocumentPickerType)
}

/**
 View controller showing how to implement the camera using the Component API of the Gini Vision Library for iOS.
 */
final class ComponentAPICameraViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    weak var delegate: ComponentAPICameraViewControllerDelegate?
    var giniConfiguration: GiniConfiguration!
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Create the camera view controller
        let cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        cameraViewController.delegate = self
        

        
        // 3. Display the camera view controller
        contentController = cameraViewController
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
        delegate?.componentAPICamera(self, didTapClose: ())
    }
}

// MARK: - CameraViewControllerDelegate

extension ComponentAPICameraViewController: CameraViewControllerDelegate {
    func camera(_ viewController: CameraViewController, didCapture document: GiniVisionDocument) {
        self.delegate?.componentAPICamera(self, didPickDocument: document)
    }
    
    func cameraDidAppear(_ viewController: CameraViewController) {
        
    }
    
    func cameraDidTapMultipageReviewButton(_ viewController: CameraViewController) {
        
    }
    
    func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType) {
        delegate?.componentAPICamera(self, didSelect: documentPicker)
    }
}


