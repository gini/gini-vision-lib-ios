//
//  NetworkHandler.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import Foundation

final class NetworkHandler {
    
    let documentService: APIService
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocument: GiniVisionDocument?
    var visionConfiguration: GiniConfiguration
    
    init(documentService: APIService, giniConfiguration: GiniConfiguration) {
        self.documentService = documentService
        self.visionConfiguration = giniConfiguration
    }
    
    // MARK: Handle analysis of document
    func analyzeDocument(visionDocument document: GiniVisionDocument,
                         delegate: AnalysisDelegate? = nil) {
        cancelAnalysis()
        visionDocument = document
        analysisDelegate = delegate
        
        documentService
            .analyzeDocument(withData: document.data,
                             cancelationToken: CancelationToken()) { [weak self] result, document, error in
                                if let analysisDelegate = self?.analysisDelegate {
                                    guard let document = document, let result = result else {
                                        if let error = error, let analysisDelegate = self?.analysisDelegate {
//                                            self?.show(error: error, analysisDelegate: analysisDelegate)
                                            return
                                        }
                                        return
                                    }
//                                    self?.present(result: result, fromDocument: document, analysisDelegate: analysisDelegate)
                                }
                                
        }
    }
    
    func cancelAnalysis() {
        documentService.cancelAnalysis()
        visionDocument = nil
        analysisDelegate = nil
    }
    
}

extension NetworkHandler: GiniVisionDelegate {
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
        if changes || (!documentService.isAnalyzing && documentService.result == nil) {
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
        self.analysisDelegate = analysisDelegate
        
        // if there is already results, present them
        if let result = documentService.result,
            let document = documentService.document {
//            present(result: result, fromDocument: document, analysisDelegate: analysisDelegate)
        }
        
        // The analysis screen is where the user should be confronted with
        // any errors occuring during the analysis process.
        // Show any errors that occured while the user was still reviewing the image here.
        // Make sure to only show errors relevant to the user.
        if let error = documentService.error {
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
