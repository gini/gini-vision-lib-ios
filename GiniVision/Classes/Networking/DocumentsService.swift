//
//  DocumentsService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

final class DocumentsService: DocumentServiceProtocol {
    
    var giniSDK: GiniSDK
    var partialDocuments: [String: PartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
        _ = self.getSession()
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
        
        self.fetchExtractions(for: partialDocumentsInfoSorted, completion: completion)
    }
    
    func cancelAnalysis() {
        if let compositeDocument = compositeDocument {
            deleteCompositeDocument(withId: compositeDocument.documentId)
        }
        
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
        compositeDocument = nil
    }
    
    func remove(document: GiniVisionDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let partialDocumentId = partialDocuments[document.id]?
                .info
                .documentId {
                deletePartialDocument(withId: partialDocumentId)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    func resetToInitialState() {
        partialDocuments.removeAll()
        analysisCancellationToken = nil
        compositeDocument = nil
    }
    
    func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = Int32(imageDocument.rotationDelta)
    }
    
    func sendFeedback(with updatedExtractions: [String: Extraction]) {
        guard let compositeDocument = self.compositeDocument else { return }
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession())
            .continueOnSuccessWith(block: { _ in
                return self.giniSDK
                    .documentTaskManager?
                    .update(compositeDocument,
                            updatedExtractions: updatedExtractions,
                            cancellationToken: nil)
            })
            .continueWith(block: { (task: BFTask?) in
                if let error = task?.error {
                    let id = self.compositeDocument?.documentId ?? ""
                    let message = "Error sending feedback for document with id: \(id) error: \(error)"
                    Log(message: message, event: .error)
                    
                    return nil
                }
                
                Log(message: "Feedback sent with \(updatedExtractions.count) extractions",
                    event: "🚀")
                
                return nil
            })
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        for index in 0..<documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        self.partialDocuments[document.id] =
            PartialDocumentInfo(info: (GINIPartialDocumentInfo(documentUrl: nil, rotationDelta: 0)),
                                order: self.partialDocuments.count)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"

        createDocument(from: document, fileName: fileName) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.info.documentUrl = createdDocument.links.document
                
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}

// MARK: - File private methods

extension DocumentsService {
    fileprivate func createDocument(from document: GiniVisionDocument,
                                    fileName: String,
                                    docType: String = "",
                                    cancellationToken: BFCancellationToken? = nil,
                                    completion: @escaping UploadDocumentCompletion) {
        Log(message: "Creating document...", event: "📝")
        
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession(with: cancellationToken))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK.documentTaskManager.createPartialDocument(withFilename: fileName,
                                                                               from: document.data,
                                                                               docType: docType,
                                                                               cancellationToken: cancellationToken)
            }).continueWith(block: { task in
                if let createdDocument = task.result as? GINIDocument {
                    Log(message: "Created document with id: \(createdDocument.documentId ?? "") " +
                        "for vision document \(document.id)", event: "📄")
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
    
    fileprivate func deleteCompositeDocument(withId id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession(with: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.deleteCompositeDocument(withId: id,
                                                                          cancellationToken: nil)
            })
            .continueWith(block: { task in
                if task.isCancelled || task.error != nil {
                    Log(message: "Error deleting composite document with id: \(id)", event: .error)
                } else {
                    Log(message: "Deleted composite document with id: \(id)", event: "🗑")
                }
                
                return nil
            })
        
    }
    
    fileprivate func deletePartialDocument(withId id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession(with: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.deletePartialDocument(withId: id,
                                                                        cancellationToken: nil)
            })
            .continueWith(block: { task in
                if task.isCancelled || task.error != nil {
                    Log(message: "Error deleting partial document with id: \(id)", event: .error)
                } else {
                    Log(message: "Deleted partial document with id: \(id)", event: "🗑")
                }
                
                return nil
            })
        
    }
    
    fileprivate func fetchExtractions(for documents: [GINIPartialDocumentInfo],
                                      completion: @escaping AnalysisCompletion) {
        Log(message: "Creating composite document...", event: "📑")

        analysisCancellationToken = BFCancellationTokenSource()
        let fileName = "Composite-\(NSDate().timeIntervalSince1970)"
        
        giniSDK
            .documentTaskManager
            .createCompositeDocument(withPartialDocumentsInfo: documents,
                                     fileName: fileName,
                                     docType: "",
                                     cancellationToken: analysisCancellationToken?.token)
            .continueOnSuccessWith { task in
                if let document = task.result as? GINIDocument {
                    Log(message: "Starting analysis for composite document with id \(document.documentId ?? "")", event: "🔎")

                    self.compositeDocument = document
                    return self.giniSDK
                        .documentTaskManager
                        .getExtractionsFor(document, cancellationToken: self.analysisCancellationToken?.token)
                }
                return BFTask<AnyObject>(error: AnalysisError.documentCreation)
            }
            .continueWith(block: handleAnalysisResults(completion: completion))
        
    }
    
    fileprivate func handleAnalysisResults(completion: @escaping AnalysisCompletion)
        -> ((BFTask<AnyObject>) -> Any?) {
            return { task in
                if task.isCancelled {
                    Log(message: "Cancelled analysis process", event: .error)
                    completion(.failure(AnalysisError.cancelled))
                    
                    return BFTask<AnyObject>.cancelled()
                }
                
                let finishedString = "Finished analysis process with"
                
                if let error = task.error {
                    Log(message: "\(finishedString) this error: \(error)", event: .error)
                    
                    completion(.failure(error))
                } else if let result = task.result as? [String: Extraction] {
                    Log(message: "\(finishedString) no errors", event: .success)
                    
                    completion(.success(result))
                } else {
                    let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                    Log(message: "\(finishedString) this error: \(error)", event: .error)
                    
                    completion(.failure(AnalysisError.unknown))
                }
                
                return nil
            }
    }
    
    fileprivate func getSession(with token: BFCancellationToken? = nil)
        -> ((BFTask<AnyObject>) -> Any?) {
            return {
                [weak self] task in
                guard let `self` = self else { return nil }
                
                if task.error != nil {
                    return self.giniSDK.sessionManager.logIn()
                }
                return task.result
            }
    }
}
