//
//  ScreenAPIViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Vision Library for iOS
 and how to process it using the Gini SDK for iOS.
 */
class ScreenAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationLabel: UILabel!
    
    var isUITest: Bool {
        return ProcessInfo.processInfo.arguments.contains("--UITest")
    }
    
    var analysisDelegate: GINIAnalysisDelegate?
    var imageData: Data?
    var result: GINIResult? {
        didSet {
            if let result = result,
               let document = document {
                show(result, fromDocument: document)
            }
        }
    }
    var document: GINIDocument?
    var errorMessage: String? {
        didSet {
            if let errorMessage = errorMessage {
                show(errorMessage: errorMessage)
            }
        }
    }
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customClientId = UserDefaults.standard.string(forKey: kSettingsGiniSDKClientIdKey) ?? ""
        let clientId = customClientId != "" ? customClientId : kGiniClientId
        
        metaInformationLabel.text = "Gini Vision Library: (\(GINIVision.versionString)) / Client id: \(clientId)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: User interaction
    @IBAction func easyLaunchGiniVision(_ sender: AnyObject) {
        
        /************************************************************************
         * CAPTURE IMAGE WITH THE SCREEN API OF THE GINI VISION LIBRARY FOR IOS *
         ************************************************************************/
        
        // 1. Create a custom configuration object
        let giniConfiguration = GINIConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.navigationBarItemTintColor = UIColor.white
        
        // Make sure the app always behaves the same when run from UITests
        if isUITest {
            giniConfiguration.onboardingShowAtFirstLaunch = false
        }
        
        // 2. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
        let vc = GINIVision.viewController(withDelegate: self, withConfiguration: giniConfiguration)
        
        // 3. Present the Gini Vision Library Screen API modally
        present(vc, animated: true, completion: nil)
        
        // 4. Handle callbacks send out via the `GINIVisionDelegate` to get results, errors or updates on other user actions
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(withImageData data: Data) {
        
        // Do not perform network tasks when UI testing.
        if isUITest {
            return
        }
        
        cancelAnalsyis()
        imageData = data
        AnalysisManager.sharedManager.analyzeDocument(withImageData: data, cancelationToken: CancelationToken(), completion: { inner in
            do {
                guard let response = try inner?(),
                      let result = response.0,
                      let document = response.1 else {
                        return self.errorMessage = "Ein unbekannter Fehler ist aufgetreten. Wiederholen"
                }
                self.document = document
                self.result = result
            } catch _ {
                self.errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
            }
        })
    }
    
    func cancelAnalsyis() {
        AnalysisManager.sharedManager.cancelAnalysis()
        result = nil
        document = nil
        errorMessage = nil
        imageData = nil
    }
    
    // MARK: Handle results from analysis process
    func show(errorMessage message: String) {
        guard let imageData = self.imageData else {
            return
        }
        
        // Display an error with a custom message and custom action on the analysis screen
        analysisDelegate?.displayError(withMessage: errorMessage, andAction: {
            self.analyzeDocument(withImageData: imageData)
        })
    }
    
    func show(_ result: GINIResult, fromDocument document: GINIDocument) {
        if let _ = analysisDelegate {
            analysisDelegate = nil
            present(result, fromDocument: document)
        }
    }
    
    func present(_ result: GINIResult, fromDocument document: GINIDocument) {
        let payFive = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasPayFive = result.filter { payFive.contains($0.0) }.count > 0
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if hasPayFive {
            let vc = storyboard.instantiateViewController(withIdentifier: "resultScreen") as! ResultTableViewController
            vc.result = result
            vc.document = document
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: false)
            }
        } else {
            let vc = storyboard.instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        
        DispatchQueue.main.async { 
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: Gini Vision delegate
extension ScreenAPIViewController: GINIVisionDelegate {
    
    func didCapture(_ imageData: Data) {
        print("Screen API received image data")
        
        // Analyze image data right away with the Gini SDK for iOS to have results in as early as possible.
        analyzeDocument(withImageData: imageData)
    }
    
    func didReview(_ imageData: Data, withChanges changes: Bool) {
        print("Screen API received updated image data with \(changes ? "changes" : "no changes")")
        
        // Analyze reviewed data because changes were made by the user during review.
        if changes {
            analyzeDocument(withImageData: imageData)
            return
        }
        
        // Present already existing results retrieved from the first analysis process initiated in `didCapture:`.
        if let result = result,
           let document = document {
            present(result, fromDocument: document)
            return
        }
        
        // Restart analysis if it was canceled and is currently not running.
        if !AnalysisManager.sharedManager.isAnalyzing {
            analyzeDocument(withImageData: imageData)
        }
    }
    
    func didCancelCapturing() {
        print("Screen API canceled capturing")
        dismiss(animated: true, completion: nil)
    }
    
    // Optional delegate methods
    func didCancelReview() {
        print("Screen API canceled review")
        
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalsyis()
    }
    
    func didShowAnalysis(_ analysisDelegate: GINIAnalysisDelegate) {
        print("Screen API started analysis screen")
        
        self.analysisDelegate = analysisDelegate
        
        // The analysis screen is where the user should be confronted with any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let errorMessage = errorMessage {
            show(errorMessage: errorMessage)
        }
        
        // Send test error message when UI testing.
        if isUITest {
            analysisDelegate.displayError(withMessage: "My network error", andAction: { print("Try again") })
        }
    }
    
    func didCancelAnalysis() {
        print("Screen API canceled analysis")
        
        analysisDelegate = nil
        
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalsyis()
    }
    
}
