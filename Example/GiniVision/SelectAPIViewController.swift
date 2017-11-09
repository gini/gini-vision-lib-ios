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
class SelectAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationLabel: UILabel!
    
    var isUITest: Bool {
        return ProcessInfo.processInfo.arguments.contains("--UITest")
    }
    
    var componentAPICoordinator: ComponentAPICoordinator?
    var analysisDelegate: AnalysisDelegate? 
    var imageData: Data?
    var result: GINIResult? {
        didSet {
            if let result = result,
                let document = document,
                analysisDelegate != nil {
                present(result, fromDocument: document)
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
        
        metaInformationLabel.text = "Gini Vision Library: (\(GiniVision.versionString)) / Client id: \(clientId)"
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
        
        // 1. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
        let vc = giniScreenAPI(withImportedDocument: nil)
        
        // 2. Present the Gini Vision Library Screen API modally
        present(vc, animated: true, completion: nil)
        
        // 3. Handle callbacks send out via the `GINIVisionDelegate` to get results, errors or updates on other user actions
    }
    
    @IBAction func launchComponentAPI(_ sender: Any) {
        componentAPICoordinator = ComponentAPICoordinator(document: nil)
        componentAPICoordinator?.delegate = self
        componentAPICoordinator?.start(from: self)
    }
    
    func giniScreenAPI(withImportedDocument document:GiniVisionDocument?) -> UIViewController {
        
        // 1. Create a custom configuration object
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.navigationBarItemTintColor = UIColor.white
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 5 * 1024 * 1024
            if document.data.count > maxFileSize {
                throw DocumentValidationError.custom(message: "Diese Datei ist leider größer als 5MB")
            }
        }
        
        // Make sure the app always behaves the same when run from UITests
        if isUITest {
            giniConfiguration.onboardingShowAtFirstLaunch = false
        }
        
        // 2. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
        return GiniVision.viewController(withDelegate: self, withConfiguration: giniConfiguration, importedDocument: document)
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(withData data: Data) {
        
        // Do not perform network tasks when UI testing.
        if isUITest {
            return
        }
        
        cancelAnalsyis()
        imageData = data
        
        print("Analysing document with size \(Double(data.count) / 1024.0)")
        AnalysisManager.sharedManager.analyzeDocument(withData: data, cancelationToken: CancelationToken(), completion: { inner in
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
            self.analyzeDocument(withData: imageData)
        })
    }
    
    func present(_ result: GINIResult, fromDocument document: GINIDocument) {
        let resultParameters = ["paymentReference", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        
        if hasExtactions {
            showResultsScreen()
        } else {            
            showNoResultsScreen()
        }
    }
    
    fileprivate func showResultsScreen() {
        let customResultsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resultScreen") as! ResultTableViewController
        customResultsScreen.result = result
        customResultsScreen.document = document
        DispatchQueue.main.async { [weak self] in
            print("Presenting results screen...")
            self?.navigationController?.pushViewController(customResultsScreen, animated: true)
            self?.dismiss(animated: true, completion: nil)
            self?.analysisDelegate = nil
            
        }
    }
    
    fileprivate func showNoResultsScreen() {
        DispatchQueue.main.async { [weak self] in
            print("Presenting no results screen...")
            guard let `self` = self, let analysisDelegate = self.analysisDelegate else { return }
            let shown = analysisDelegate.tryDisplayNoResultsScreen()
            if !shown {
                let customNoResultsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
                self.navigationController!.pushViewController(customNoResultsScreen, animated: true)
                self.dismiss(animated: true, completion: nil)
            }
            self.analysisDelegate = nil
        }
    }
}

extension SelectAPIViewController: ComponentAPICoordinatorDelegate {
    func didFinish() {
        self.componentAPICoordinator = nil
    }
}

// MARK: Gini Vision delegate
extension SelectAPIViewController: GiniVisionDelegate {
    
    func didCapture(document: GiniVisionDocument) {
        print("Screen API received image data")
        
        // Analyze document data right away with the Gini SDK for iOS to have results in as early as possible.
        analyzeDocument(withData: document.data)
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        print("Screen API received updated image data with \(changes ? "changes" : "no changes")")
        
        // Analyze reviewed document when changes were made by the user during review or there is no result and is not analysing.
        if changes || (!AnalysisManager.sharedManager.isAnalyzing && result == nil) {
            analyzeDocument(withData: document.data)
            return
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
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
        print("Screen API started analysis screen")
        self.analysisDelegate = analysisDelegate
        
        // if there is already results, present them
        if let result = result,
            let document = document {
            present(result, fromDocument: document)
        }
        
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
