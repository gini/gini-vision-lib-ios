//
//  GiniScreenAPICoordinator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation
import Gini_iOS_SDK

/**
 The GiniVisionResultsDelegate protocol defines methods that allow you to handle the analysis result.
 */
@objc public protocol GiniVisionResultsDelegate: class {
    /**
     Called when the analysis finished with results
     
     - parameter results: Dictionary with all the extractions
     - parameter sendFeedbackBlock: Block used to send feeback once the results have been corrected
     */
    func giniVisionAnalysisDidFinish(with results: [String: Extraction],
                                     sendFeedbackBlock: @escaping ([String: Extraction]) -> Void)
    
    /**
     Called when the analysis finished without results.
     
     - parameter showingNoResultsScreen: Indicated if the `ImageAnalysisNoResultsViewController` has been shown
     */
    func giniVisionAnalysisDidFinishWithoutResults(_ showingNoResultsScreen: Bool)
    
    /**
     Called when the analysis was cancelled.
     */
    func giniVisionDidCancelAnalysis()
}

extension GiniScreenAPICoordinator {
    fileprivate struct AssociatedKey {
        static var documentService = "documentService"
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
    
    var documentService: DocumentServiceProtocol? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.documentService) as? DocumentServiceProtocol
        }
        
        set {
            if let value = newValue {
                objc_setAssociatedObject(self,
                                         &AssociatedKey.documentService,
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
        
        if let sdk = builder?.build() {
            if giniConfiguration.multipageEnabled {
                self.documentService = MultipageDocumentsService(sdk: sdk)
            } else {
                self.documentService = SinglePageDocumentsService(sdk: sdk)
            }
        }
    }
    
    func deliver(result: [String: Extraction], analysisDelegate: AnalysisDelegate) {
        let resultParameters = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if hasExtactions {
                self.resultsDelegate?
                    .giniVisionAnalysisDidFinish(with: result) { [weak self] updatedExtractions in
                                    guard let `self` = self else { return }
                                    self.documentService?.sendFeedback(with: updatedExtractions)
                }
            } else {
                self.resultsDelegate?
                    .giniVisionAnalysisDidFinishWithoutResults(analysisDelegate.tryDisplayNoResultsScreen())
            }
        }
    }
}

extension GiniScreenAPICoordinator: GiniVisionDelegate {
    
    func didCancelCapturing() {
        resultsDelegate?.giniVisionDidCancelAnalysis()        
    }
    
    func didCapture(document: GiniVisionDocument, analysisDelegate: AnalysisDelegate) {
    
    }
    
    func didCapture(document: GiniVisionDocument, uploadDelegate: UploadDelegate) {        
        documentService?.upload(document: document) { [weak self, weak uploadDelegate] result in
            guard let `self` = self, let uploadDelegate = uploadDelegate else { return }
            switch result {
            case .success:
                if document is GiniImageDocument && self.giniConfiguration.multipageEnabled {
                    uploadDelegate.uploadDidComplete(for: document)
                } else {
                    
                }
            case .failure(let error):
                uploadDelegate.uploadDidFail(for: document, with: error)
            }
        }
    }
    
    func didReview(documents: [GiniVisionDocument]) {
        // It is necessary to check the order when using multipage before
        // creating the composite document
        if let documentService = documentService as? MultipageDocumentsService {
            documentService.sortDocuments(withSameOrderAs: documents)
        }
        
        // And review the changes for each document recursively.
        for document in (documents.compactMap { $0 as? GiniImageDocument }) {
            documentService?.update(imageDocument: document)
        }

    }
    
    func didCancelReview(for document: GiniVisionDocument) {
        documentService?.remove(document: document)
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {        
        documentService?.startAnalysis { result in
            switch result {
            case .success(let extractions):
                self.deliver(result: extractions, analysisDelegate: analysisDelegate)
            case .failure(let error):
                guard let error = error as? GiniVisionError else { return }
                analysisDelegate.displayError(withMessage: error.message, andAction: {
                    self.didShowAnalysis(analysisDelegate)
                })
            }
        }
    }
    
    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        documentService?.cancelAnalysis()
    }
}
