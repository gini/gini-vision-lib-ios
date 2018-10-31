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
                     giniConfiguration: GiniConfiguration,
                     documentMetadata: GINIDocumentMetadata?) {
        self.init(withDelegate: nil,
                  giniConfiguration: giniConfiguration)
        self.visionDelegate = self
        self.resultsDelegate = resultsDelegate
        
        let builder = GINISDKBuilder.anonymousUser(withClientID: client.clientId,
                                                   clientSecret: client.clientSecret,
                                                   userEmailDomain: client.clientEmailDomain)
        
        if let sdk = builder?.build() {
            self.documentService = DocumentsService(sdk: sdk, metadata: documentMetadata)
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
                                    self.documentService?.resetToInitialState()
                }
            } else {
                self.resultsDelegate?
                    .giniVisionAnalysisDidFinishWithoutResults(analysisDelegate.tryDisplayNoResultsScreen())
                self.documentService?.resetToInitialState()
            }
        }
    }
}

// MARK: - Networking methods

extension GiniScreenAPICoordinator {
    fileprivate func startAnalysis(networkDelegate: GiniVisionNetworkDelegate) {
        self.documentService?.startAnalysis { result in
            switch result {
            case .success(let extractions):
                self.deliver(result: extractions, analysisDelegate: networkDelegate)
            case .failure(let error):
                let error = error as? AnalysisError ?? AnalysisError.unknown
                guard error != .cancelled else { return }
                
                networkDelegate.displayError(withMessage: error.message, andAction: {
                    self.startAnalysis(networkDelegate: networkDelegate)
                })
            }
        }
    }
    
    fileprivate func upload(document: GiniVisionDocument,
                            didComplete: @escaping (GiniVisionDocument) -> Void,
                            didFail: @escaping (GiniVisionDocument, Error) -> Void) {
        documentService?.upload(document: document) { result in
            switch result {
            case .success:
                didComplete(document)
            case .failure(let error):
                didFail(document, error)
            }
        }
    }
    
    fileprivate func uploadAndStartAnalysis(document: GiniVisionDocument,
                                            networkDelegate: GiniVisionNetworkDelegate,
                                            uploadDidFail: @escaping () -> Void) {
        self.upload(document: document, didComplete: { _ in
            self.startAnalysis(networkDelegate: networkDelegate)
        }, didFail: { _, error in
            let error = error as? GiniVisionError ?? AnalysisError.documentCreation
            networkDelegate.displayError(withMessage: error.message, andAction: {
                uploadDidFail()
            })
        })
    }
}

// MARK: - GiniVisionDelegate

extension GiniScreenAPICoordinator: GiniVisionDelegate {
    func didCancelCapturing() {
        resultsDelegate?.giniVisionDidCancelAnalysis()        
    }
    
    func didCapture(document: GiniVisionDocument, networkDelegate: GiniVisionNetworkDelegate) {
        // When an non reviewable document or an image in multipage mode is captured,
        // it has to be uploaded right away.
        if giniConfiguration.multipageEnabled || !document.isReviewable {
            if !document.isReviewable {
                self.uploadAndStartAnalysis(document: document, networkDelegate: networkDelegate, uploadDidFail: {
                    self.didCapture(document: document, networkDelegate: networkDelegate)
                })
            } else if giniConfiguration.multipageEnabled {
                // When multipage is enabled the document updload result should be communicated to the network delegate
                upload(document: document,
                       didComplete: networkDelegate.uploadDidComplete,
                       didFail: networkDelegate.uploadDidFail)
            }            
        }
    }
    
    func didReview(documents: [GiniVisionDocument], networkDelegate: GiniVisionNetworkDelegate) {
        // It is necessary to check the order when using multipage before
        // creating the composite document
        if giniConfiguration.multipageEnabled {
            documentService?.sortDocuments(withSameOrderAs: documents)
        }
        
        // And review the changes for each document recursively.
        for document in (documents.compactMap { $0 as? GiniImageDocument }) {
            documentService?.update(imageDocument: document)
        }
        
        // In multipage mode the analysis can be triggered once the documents have been uploaded.
        // However, in single mode, the analysis can be triggered right after capturing the image.
        // That is why the document upload shuld be done here and start the analysis afterwards
        if giniConfiguration.multipageEnabled {
            self.startAnalysis(networkDelegate: networkDelegate)
        } else {
            self.uploadAndStartAnalysis(document: documents[0], networkDelegate: networkDelegate, uploadDidFail: {
                self.didReview(documents: documents, networkDelegate: networkDelegate)
            })
        }
    }
    
    func didCancelReview(for document: GiniVisionDocument) {
        documentService?.remove(document: document)
    }
    
    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        if pages.type == .image {
            documentService?.cancelAnalysis()
        } else {
            documentService?.resetToInitialState()
        }
    }
}
