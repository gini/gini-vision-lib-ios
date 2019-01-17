//
//  AccountingDocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/14/19.
//

import Foundation
import Gini_iOS_SDK

final class AccountingDocumentService: DocumentServiceProtocol {
    var giniSDK: GiniSDK
    var metadata: GINIDocumentMetadata?
    var document: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init(sdk: GiniSDK, metadata: GINIDocumentMetadata?) {
        self.giniSDK = sdk
        self.metadata = metadata
        self.giniSDK.sessionManager.logIn()
    }
    
    func cancelAnalysis() {
        if let document = document {
            delete(document)
        }
        
        analysisCancellationToken?.cancel()
        resetToInitialState()
    }
    
    func remove(document: GiniVisionDocument) {
        // You can only remove the current document, since multipage is not supported
        if let document = self.document {
            delete(document)
        }
    }
    
    func resetToInitialState() {
        analysisCancellationToken = nil
        document = nil
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        fetchExtractions(completion: completion)
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        // No need to sort documents since there is only one
    }
    
    func upload(document: GiniVisionDocument, completion: UploadDocumentCompletion?) {
        let fileName = "Document-\(NSDate().timeIntervalSince1970)"
        analysisCancellationToken = BFCancellationTokenSource()
        
        createDocument(from: document,
                       fileName: fileName,
                       cancellationToken: analysisCancellationToken?.token) { result in
            switch result {
            case .success(let createdDocument):
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    func update(imageDocument: GiniImageDocument) {
        // Nothing must be updated.
    }
    
}

// MARK: Fileprivate

fileprivate extension AccountingDocumentService {
    func createDocument(from document: GiniVisionDocument,
                        fileName: String,
                        docType: String = "",
                        cancellationToken: BFCancellationToken? = nil,
                        completion: @escaping UploadDocumentCompletion) {
        Log(message: "Creating document...", event: "📝")
        
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession(with: cancellationToken))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK.documentTaskManager.createDocument(withFilename: fileName,
                                                                        from: document.data,
                                                                        docType: docType,
                                                                        metadata: self?.metadata,
                                                                        cancellationToken: cancellationToken)
            }).continueWith(block: { [weak self] task in
                guard let self = self else { return nil }
                if let createdDocument = task.result as? GINIDocument {
                    Log(message: "Created document with id: \(createdDocument.documentId ?? "") " +
                        "for vision document \(document.id)", event: "📄")
                    
                    self.document = createdDocument
                    completion(.success(createdDocument))
                } else if task.isCancelled {
                    Log(message: "Document creation was cancelled", event: .error)
                    completion(.failure(AnalysisError.cancelled))
                } else {
                    Log(message: "Document creation failed", event: .error)
                    completion(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
    }
    
    func delete(_ document: GINIDocument) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession(with: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.delete(document)
            })
            .continueWith(block: { task in
                if task.isCancelled || task.error != nil {
                    Log(message: "Error deleting document with id: \(document.documentId ?? "")",
                        event: .error)
                } else {
                    Log(message: "Deleted document with id: \(document.documentId ?? "")", event: "🗑")
                    self.document = nil
                }
                
                return nil
            })
    }
    
    func fetchExtractions(completion: @escaping AnalysisCompletion) {
        Log(message: "Starting analysis for document with id \(document?.documentId ?? "")",
            event: "🔎")
        if analysisCancellationToken == nil {
            analysisCancellationToken = BFCancellationTokenSource()
        }
        
        giniSDK
            .documentTaskManager
            .getExtractionsFor(document, cancellationToken: self.analysisCancellationToken?.token)
            .continueWith(block: handleAnalysisResults(completion: completion))
    }
}
