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
    
    func present(result: [String: Extraction]) {
        let resultParameters = ["paymentRecipient", "iban", "bic", "paymentReference", "amountToPay"]
        let hasExtactions = result.filter { resultParameters.contains($0.0) }.count > 0
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if hasExtactions {
                self.resultsDelegate?
                    .giniVision(self.visionDocuments,
                                analysisDidFinishWithResults: result) { [weak self] updatedExtractions in
                                    guard let `self` = self else { return }
                                    self.documentService?.sendFeedback(with: updatedExtractions)
                }
            } else {
                self.resultsDelegate?
                    .giniVision(self.visionDocuments,
                                analysisDidFinishWithNoResults: self.tryDisplayNoResultsScreen())
            }
        }
    }
    
    func show(error: Error) {
        let errorMessage = "Es ist ein Fehler aufgetreten. Wiederholen"
        
        // Display an error with a custom message and custom action on the analysis screen
        displayError(withMessage: errorMessage, andAction: { [weak self] in
            guard let `self` = self else { return }
            
            self.documentService?.startAnalysis { result in
                switch result {
                case .success(let extractions):
                    self.present(result: extractions)
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
    
}

extension GiniScreenAPICoordinator: GiniVisionDelegate {
    
    func didCancelCapturing() {
        resultsDelegate?.giniVision([], analysisDidCancel: true)
        
    }
        
    func didCapture(document: GiniVisionDocument) {
        var uploadDocumentCompletionHandler: UploadDocumentCompletion? = nil
        
        if giniConfiguration.multipageEnabled {
            uploadDocumentCompletionHandler = { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print("Partial document creation error: ", error)
                }
                // TODO: Update upload status in MultipageReviewViewController
            }
        }
        
        documentService?.upload(document: document,
                                completion: uploadDocumentCompletionHandler)
    }
    
    func didReview(document: GiniVisionDocument, withChanges changes: Bool) {
        var documentParameters: [String: Any] = [:]
        if let document = document as? GiniImageDocument,
            let key = documentService?.rotationDeltaKey {
            documentParameters[key] = document.rotationDelta
            documentService?.update(parameters: documentParameters, for: document)
        }
    }
    
    func didReview(documents: [GiniVisionDocument]) {
        // There is the need to check the order when using multipage before
        // creating composite document
        if let documentService = documentService as? MultipageDocumentsService {
            documentService.orderDocuments(givenVisionDocumentIds: documents.map { $0.id })
        }
        
        // And review the changes for each document recursively.
        for document in documents {
            didReview(document: document, withChanges: false)
        }

    }
    
    func didCancelReview(for document: GiniVisionDocument) {
        documentService?.remove(document: document)
    }
    
    func didShowAnalysis(_ analysisDelegate: AnalysisDelegate) {        
        documentService?.startAnalysis { result in
            switch result {
            case .success(let extractions):
                self.present(result: extractions)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func didCancelAnalysis() {
        // Cancel analysis process to avoid unnecessary network calls.
        documentService?.cancelAnalysis()
    }
}
