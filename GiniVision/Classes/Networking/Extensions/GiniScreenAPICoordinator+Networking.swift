//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation

public protocol GiniVisionResultsDelegate: class {
    func giniVision(_ documents: [GiniVisionDocument], analysisDidCancel: Void)
    func giniVision(_ documents: [GiniVisionDocument], analysisDidFinishWithResults results: [String: Any])
    func giniVision(_ documents: [GiniVisionDocument], analysisDidFinishWithNoResults showingNoResultsScreen: Bool)
}

extension GiniScreenAPICoordinator {
    fileprivate struct AssociatedKey {
        static var apiService = "apiService"
        static var resultsDelegate = "resultsDelegate"
    }
    
    fileprivate var resultsDelegate: GiniVisionResultsDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.resultsDelegate) as? GiniVisionResultsDelegate
        }
        
        set {
            if let value = newValue {
                objc_setAssociatedObject(self,
                                         &AssociatedKey.resultsDelegate,
                                         value,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    fileprivate var apiService: APIService? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.apiService) as? APIService
        }
        
        set {
            if let value = newValue {
                objc_setAssociatedObject(self,
                                         &AssociatedKey.apiService,
                                         value,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    convenience init(credentials: (id: String?, password: String?),
                     resultsDelegate: GiniVisionResultsDelegate,
                     giniConfiguration: GiniConfiguration) {
        self.init(withDelegate: nil,
                  giniConfiguration: giniConfiguration)
        self.visionDelegate = self
        self.resultsDelegate = resultsDelegate
        self.apiService = APIService(id: credentials.id, password: credentials.password)
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(visionDocument document: GiniVisionDocument) {
        cancelAnalysis()
        
        apiService?
            .analyzeDocument(withData: document.data,
                             cancelationToken: CancelationToken()) { [weak self] result, document, error in
                                guard let result = result else {
                                    if let error = error {
                                        self?.show(error: error)
                                        return
                                    }
                                    return
                                }
                                self?.present(result: result)
        }
    }
    
    func present(result: GINIResult) {
        let resultParameters = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        let results = (result.reduce([:]) { dict, kv in
            var dict = dict
            dict[kv.key] = kv.value.value
            return dict
        })
        
        if hasExtactions {
            if let results = results as? [String: Any] {
                if let visionDocument = visionDocument {
                    self.resultsDelegate?.giniVision([visionDocument], analysisDidFinishWithResults: results)
                }
                
            }
        } else {
            if let visionDocument = visionDocument {
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.resultsDelegate?.giniVision([visionDocument],
                                                     analysisDidFinishWithNoResults: self.tryDisplayNoResultsScreen())
                }
            }
        }
    }
    
    func cancelAnalysis() {
        apiService?.cancelAnalysis()
    }
    
    func show(error: Error) {
        guard let document = self.visionDocument else {
            return
        }
        let errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
        
        // Display an error with a custom message and custom action on the analysis screen
        displayError(withMessage: errorMessage, andAction: { [weak self] in
            self?.analyzeDocument(visionDocument: document)
        })
    }
    
}

extension GiniScreenAPICoordinator: GiniVisionDelegate {
    
    func didCancelCapturing() {
        resultsDelegate?.giniVision([], analysisDidCancel: ())
    }
    
    func didCapture(document: GiniVisionDocument) {
        // Analyze document data right away with the Gini SDK for iOS to have results in as early as possible.
        self.analyzeDocument(visionDocument: document)
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        // Analyze reviewed document when changes were made by the user during review or
        // there is no result and is not analysing.
        guard let apiService = apiService else {
            return
        }
        if changes || (!apiService.isAnalyzing  && apiService.result == nil) {
            self.analyzeDocument(visionDocument: document)
            
            return
        }
    }
    
    // Optional delegate methods
    func didCancelReview() {
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalysis()
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
        
        // if there is already results, present them
        if let result = apiService?.result {
            present(result: result)
        }
        
        // The analysis screen is where the user should be confronted with
        // any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let error = apiService?.error {
            show(error: error)
        }
    }
    
    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalysis()
    }
}

/**
 Simple cancelation token implementation.
 Used in asychronous tasks.
 */
class CancelationToken {
    
    /**
     Cancel propoerty to check the current cancelled state of the object.
     */
    var cancelled = false
    
    /**
     Sets the state of the token to cancelled.
     */
    func cancel() {
        cancelled = true
    }
    
}

