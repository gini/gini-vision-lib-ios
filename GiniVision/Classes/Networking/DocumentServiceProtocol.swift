//
//  DocumentServiceProtocol.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini_iOS_SDK

public typealias Extraction = GINIExtraction

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum AnalysisError: Error {
    case cancelled
    case documentCreation
    case unknown
}

typealias UploadDocumentCompletion = (Result<GINIDocument>) -> Void
typealias AnalysisCompletion = (Result<[String: Extraction]>) -> Void

protocol DocumentServiceProtocol: class {
    
    var giniSDK: GiniSDK { get }
    var isAnalyzing: Bool { get }
    var compositeDocument: GINIDocument? { get }
    
    init(sdk: GiniSDK)
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func cancelAnalysis()
    func remove(document: GiniVisionDocument)
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?)
    func update(parameters: [String: Any], for document: GiniVisionDocument)
}

extension DocumentServiceProtocol {
    
    var rotationDeltaKey: String { return "rotationDelta" }
    
    func upload(document: GiniVisionDocument) {
        self.upload(document: document,
                    completion: nil)
    }
    
    func createDocument(from document: GiniVisionDocument,
                        fileName: String,
                        docType: String = "",
                        cancellationToken: BFCancellationToken,
                        completion: @escaping UploadDocumentCompletion) {
        print("Creating document for: ", document.id)
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: cancellationToken))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK.documentTaskManager.createPartialDocument(withFilename: fileName,
                                                                               from: document.data,
                                                                               docType: docType,
                                                                               cancellationToken: cancellationToken)
            }).continueWith(block: { task in
                if let createdDocument = task.result as? GINIDocument {
                    print("📄 Created document with id:", createdDocument.documentId ?? "",
                          "for vision document:", document.id)
                    completion(.success(createdDocument))
                } else if task.isCancelled {
                    completion(.failure(AnalysisError.cancelled))
                } else {
                    completion(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
    }
    
    func deleteCompositeDocument(withId id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                    self?.giniSDK.documentTaskManager.deleteDocument(withId: id,
                                                                    cancellationToken: nil)
            })
    }
    
    func deletePartialDocument(withId id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.deletePartialDocument(withId: id,
                                                                        cancellationToken: nil)
            })
    }
    
    func fetchExtractions(for documents: [PartialDocumentInfo], completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfo = documents.map { $0.toDictionary() }
        giniSDK
            .documentTaskManager
            .createCompositeDocument(withPartialDocumentsInfo: partialDocumentsInfo,
                                     fileName: "",
                                     docType: "",
                                     cancellationToken: nil)
            .continueOnSuccessWith { task in
                if let document = task.result as? GINIDocument {
                    return self.giniSDK.documentTaskManager.getExtractionsFor(document)
                }
                return BFTask<AnyObject>(error: AnalysisError.documentCreation)
            }
            .continueWith(block: handleAnalysisResults(completion: completion))
        
    }
    
    func handleAnalysisResults(completion: @escaping AnalysisCompletion)
        -> ((BFTask<AnyObject>) -> Any?) {
            return { task in
                if task.isCancelled {
                    print("❌ Cancelled analysis process")
                    completion(.failure(AnalysisError.documentCreation))
                    
                    return BFTask<AnyObject>.cancelled()
                }
                
                let finishedString = "Finished analysis process with"
                
                if let error = task.error {
                    print("❌", finishedString, "this error: \(error)")
                    
                    completion(.failure(error))
                } else if let result = task.result as? [String: Extraction] {
                    print("✅", finishedString, "no errors")
                    
                    completion(.success(result))
                } else {
                    let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                    print("❌", finishedString, "this error: \(error)")
                    
                    completion(.failure(AnalysisError.unknown))
                }
                
                return nil
            }
    }
    
    func sendFeedback(with updatedExtractions: [String: Extraction]) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock())
            .continueOnSuccessWith(block: { _ in
                return self.giniSDK
                .documentTaskManager?
                    .update(self.compositeDocument,
                            updatedExtractions: updatedExtractions,
                            cancellationToken: nil)
            })
            .continueWith(block: { (task: BFTask?) in
                guard let extractions = task?.result as? NSMutableDictionary else {
                    print("Error sending feedback for document with id: ",
                          String(describing: self.compositeDocument?.documentId))
                    return nil
                }
                
                print("🚀 Feedback sent with \(extractions.count) extractions")
                return nil
            })
    }
    
    func sessionBlock(cancellationToken token: BFCancellationToken? = nil)
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
