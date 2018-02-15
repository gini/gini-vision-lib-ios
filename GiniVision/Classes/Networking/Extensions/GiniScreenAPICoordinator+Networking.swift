//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation

extension GiniScreenAPICoordinator {
    fileprivate struct AssociatedKey {
        static var APIService = "APIService"
    }
    
    fileprivate var apiService: APIService? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.APIService) as? APIService
        }
        
        set {
            if let value = newValue {
                objc_setAssociatedObject(self,
                                         &AssociatedKey.APIService,
                                         value,
                                         objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
        
    convenience init(credentials: (id: String?, password: String?),
                     giniConfiguration: GiniConfiguration) {
        self.init(withDelegate: nil,
                  giniConfiguration: giniConfiguration)
        self.visionDelegate = self
        self.apiService = APIService(id: credentials.id, password: credentials.password)
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(visionDocument document: GiniVisionDocument) {
        cancelAnalysis()
        
        apiService?
            .analyzeDocument(withData: document.data,
                             cancelationToken: CancelationToken()) { [weak self] result, document, error in
//                                if let analysisDelegate = self?.analysisDelegate {
//                                    guard let document = document, let result = result else {
//                                        if let error = error, let analysisDelegate = self?.analysisDelegate {
////                                            self?.show(error: error, analysisDelegate: analysisDelegate)
//                                            return
//                                        }
//                                        return
//                                    }
//                                    //                                    self?.present(result: result, fromDocument: document, analysisDelegate: analysisDelegate)
//                                }
                                
        }
    }
    
    func cancelAnalysis() {
        apiService?.cancelAnalysis()
    }
    
}

extension GiniScreenAPICoordinator: GiniVisionDelegate {
    func didCapture(_ imageData: Data) {
        print()
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
    
    func didCancelCapturing() {
        //delegate?.screenAPI(coordinator: self, didFinish: ())
    }
    
    // Optional delegate methods
    func didCancelReview() {
        // Cancel analysis process to avoid unnecessary network calls.
        cancelAnalysis()
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {
        
        // if there is already results, present them
        if let result = apiService?.result,
            let document = apiService?.document {
            //            present(result: result, fromDocument: document, analysisDelegate: analysisDelegate)
        }
        
        // The analysis screen is where the user should be confronted with
        // any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let error = apiService?.error {
            //            show(error: error, analysisDelegate: analysisDelegate)
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

