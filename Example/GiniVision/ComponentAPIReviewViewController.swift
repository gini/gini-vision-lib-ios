//
//  ComponentAPIReviewViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

/**
 View controller showing how to implement the review screen using the Component API of the Gini Vision Library for iOS and
 how to process the previously captured image using the Gini SDK for iOS
 */
class ComponentAPIReviewViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    var contentController = UIViewController()
    
    /**
     The image data of the captured document to be reviewed.
     */
    var imageData: Data!
    
    fileprivate var originalData: Data?
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalData = imageData
        
        // Analogouse to the Screen API the image data should be analyzed right away with the Gini SDK for iOS
        // to have results in as early as possible.
        AnalysisManager.sharedManager.analyzeDocument(withImageData: imageData, cancelationToken: CancelationToken(), completion: nil)
        
        /*************************************************************************
         * REVIEW SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
         *************************************************************************/
        
        // (1. If not already done: Create and set a custom configuration object)
        // See `ComponentAPICameraViewController.swift` for implementation details.
        
        let imageDocument = GiniImageDocument(data: imageData)
        
        // 2. Create the review view controller
        contentController = ReviewViewController(imageDocument, success:
            { document in
                print("Component API review view controller received image data")
                // Update current image data when image is rotated by user
                self.imageData = document.data
            }, failure: { error in
                print("Component API review view controller received error:\n\(error)")
            })
        
        // 3. Display the review view controller
        displayContent(contentController)
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        
        // Cancel analysis process to avoid unnecessary network calls.
        if parent == nil {
            AnalysisManager.sharedManager.cancelAnalysis()
        }
    }
    
    // Displays the content controller inside the container view
    func displayContent(_ controller: UIViewController) {
        self.addChildViewController(controller)
        controller.view.frame = self.containerView.bounds
        self.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    // MARK: User actions
    @IBAction func showAnalysis(_ sender: AnyObject) {
        
        // Analyze reviewed data because changes were made by the user during review.
        if imageData != originalData {
            originalData = imageData
            AnalysisManager.sharedManager.analyzeDocument(withImageData: imageData, cancelationToken: CancelationToken(), completion: nil)
            performSegue(withIdentifier: "showAnalysis", sender: self)
            return
        }
        
        // Present already existing results retrieved from the first analysis process initiated in `viewDidLoad`.
        if let result = AnalysisManager.sharedManager.result,
           let document = AnalysisManager.sharedManager.document {
            handleAnalysis(result, fromDocument: document)
            return
        }
        
        // Restart analysis if it was canceled and is currently not running.
        if !AnalysisManager.sharedManager.isAnalyzing {
            AnalysisManager.sharedManager.analyzeDocument(withImageData: imageData, cancelationToken: CancelationToken(), completion: nil)
        }
        
        // Show analysis screen if no results are in yet and no changes were made.
        performSegue(withIdentifier: "showAnalysis", sender: self)
    }
    
    // MARK: Handle results from analysis process
    func handleAnalysis(_ result: GINIResult, fromDocument document: GINIDocument) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = result.filter { payFive.contains($0.0) }.count > 0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if hasPayFive {
            let vc = storyboard.instantiateViewController(withIdentifier: "resultScreen") as! ResultTableViewController
            vc.result = result
            vc.document = document
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnalysis" {
            if let vc = segue.destination as? ComponentAPIAnalysisViewController {
                // Set image data as input for the analysis view controller
                vc.imageData = imageData
            }
        }
    }
    
}

