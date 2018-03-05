//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation
import Gini_iOS_SDK

@objc public protocol GiniVisionResultsDelegate: class {
    func giniVision(_ documents: [GiniVisionDocument], analysisDidCancel: Bool)
    func giniVision(_ documents: [GiniVisionDocument],
                    analysisDidFinishWithResults results: [String: Extraction],
                    sendFeedback: @escaping ([String: Extraction]) -> Void)
    func giniVision(_ documents: [GiniVisionDocument], analysisDidFinishWithNoResults showingNoResultsScreen: Bool)
}

extension GiniScreenAPICoordinator {
    fileprivate struct AssociatedKey {
        static var apiService = "apiService"
        static var resultsDelegate = "resultsDelegate"
    }
    
    var resultsDelegate: GiniVisionResultsDelegate? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.resultsDelegate) as? GiniVisionResultsDelegate
        }
        
        set {
            if let value = newValue {
                objc_setAssociatedObject(self,
                                         &AssociatedKey.resultsDelegate,
                                         value,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    var apiService: APIService? {
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
    
    convenience init(client: GiniClient,
                     resultsDelegate: GiniVisionResultsDelegate,
                     giniConfiguration: GiniConfiguration) {
        self.init(withDelegate: nil,
                  giniConfiguration: giniConfiguration)
        self.visionDelegate = self
        self.resultsDelegate = resultsDelegate
        
        let builder = GINISDKBuilder.anonymousUser(withClientID: client.clientId,
                                                   clientSecret: client.clientSecret,
                                                   userEmailDomain: client.clientEmailDomain)
        self.apiService = APIService(sdk: builder?.build())
    }
    
    func analyzeDocument(visionDocument document: GiniVisionDocument) {
        cancelAnalysis()
        
        apiService?
            .analyzeDocument(withData: document.data,
                             cancelationToken: CancelationToken()) { [weak self] result, _, error in
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
    
    func present(result: [String: Extraction]) {
        let resultParameters = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        
        if hasExtactions {
            // TODO: Handle more documents
            if let visionDocument = visionDocuments.first {
                self.resultsDelegate?.giniVision([visionDocument],
                                                 analysisDidFinishWithResults: result) { [weak self] feedback in
                    guard let `self` = self else { return }                    
                    self.apiService?.sendFeedback(withResults: feedback)
                }
            }
        } else {
            // TODO: Handle more documents
            if let visionDocument = visionDocuments.first {
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
        // TODO: Handle more documents
        guard let document = self.visionDocuments.first else {
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
        resultsDelegate?.giniVision([], analysisDidCancel: true)
    }
    
    func didCapture(document: GiniVisionDocument) {
        // Analyze document data right away with the Gini SDK for iOS to have results in as early as possible.
        if document.type != .image { // TODO: Add multipage support
            self.analyzeDocument(visionDocument: document)
        }
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
