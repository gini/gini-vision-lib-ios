//
//  ComponentAPICameraViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 16/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision

/**
 View controller showing how to implement the camera using the Component API of the Gini Vision Library for iOS.
 */
class ComponentAPICameraViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    var document: GiniVisionDocument?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*************************************************************************
         * CAMERA SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         *************************************************************************/
        
        // 1. Create and set a custom configuration object needs to be done once before using any component of the Component API.
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        GiniVision.setConfiguration(giniConfiguration)
        
        // 2. Create the camera view controller
        contentController = CameraViewController(successBlock:
            { document, _ in
                self.document = document
                DispatchQueue.main.async {
                    self.goToNextScreen(withDocument: document)
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
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let document = document {
            if let vc = segue.destination as? ComponentAPIReviewViewController {
                vc.document = document
            } else if let vc = segue.destination as? ComponentAPIAnalysisViewController {
                vc.document = document
            }
            self.document = nil
        }
    }
    
    fileprivate func goToNextScreen(withDocument document:GiniVisionDocument) {
        if document.isReviewable {
            performSegue(withIdentifier: "showReview", sender: nil)
        } else {
            performSegue(withIdentifier: "showAnalysisFromCamera", sender: self)
        }
    }
    
}

