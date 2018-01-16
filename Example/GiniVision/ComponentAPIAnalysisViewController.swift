//
//  ComponentAPIAnalysisViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 15/07/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

protocol ComponentAPIAnalysisViewControllerDelegate:class {
    func componentAPIAnalysis(viewController: ComponentAPIAnalysisViewController, didTapErrorButton: ())
}

/**
 View controller showing how to implement the analysis screen using the Component API of the Gini Vision Library for iOS and
 how to process the previously reviewed image using the Gini SDK for iOS
 */
final class ComponentAPIAnalysisViewController: UIViewController {
    
    /**
     The image data of the captured document to be reviewed.
     */
    var document: GiniVisionDocument?
    weak var delegate: ComponentAPIAnalysisViewControllerDelegate?
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    @IBOutlet var errorButton: UIButton!
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorButton.alpha = 0.0
        
        /***************************************************************************
         * ANALYSIS SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         ***************************************************************************/
        
        // (1. If not already done: Create and set a custom configuration object)
        // See `ComponentAPICameraViewController.swift` for implementation details.
        
        // 2. Create the analysis view controller
        guard let document = document else { return }
        
        contentController = AnalysisViewController(document: document)

        // 3. Display the analysis view controller
        displayContent(contentController)
        (contentController as? AnalysisViewController)?.showAnimation()
    }
    
    // Displays the content controller inside the container view
    func displayContent(_ controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    // MARK: User actions
    @IBAction func errorButtonTapped(_ sender: AnyObject) {
        (contentController as? AnalysisViewController)?.showAnimation()
        hideErrorButton()
        delegate?.componentAPIAnalysis(viewController: self, didTapErrorButton: ())
    }
    
    // MARK: Error button handling
    func displayError(_ error: Error?) {
        if let error = error {
            print(error)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            (self.contentController as? AnalysisViewController)?.hideAnimation()
            self.showErrorButton()
        }
    }
    
    func showErrorButton() {
        guard errorButton.alpha != 1.0 else {
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.errorButton.alpha = 1.0
        }
    }
    
    func hideErrorButton() {
        guard errorButton.alpha != 0.0 else {
            return
        }
        UIView.animate(withDuration: 0.5) {
            self.errorButton.alpha = 0.0
        }
    }

}

