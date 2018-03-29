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
    
    init(sdk: GiniSDK)
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func cancelAnalysis()
    func upload(document: GiniVisionDocument)
    func sendFeedback(withResults results: [String: Extraction])
}

extension DocumentServiceProtocol {
    
    func createDocument(from document: GiniVisionDocument,
                        fileName: String,
                        docType: String = "",
                        cancellationToken: BFCancellationToken,
                        completion: @escaping UploadDocumentCompletion) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSessionBlock(cancellationToken: cancellationToken))
            .continueOnSuccessWith(block: { [weak self] _ in
                return self?.giniSDK.documentTaskManager.createDocument(withFilename: fileName,
                                                                        from: document.data,
                                                                        docType: docType,
                                                                        cancellationToken: cancellationToken)
            }).continueWith(block: { task in
                if let createdDocument = task.result as? GINIDocument {
                    print("📄 Created document with id: \(createdDocument.documentId ?? "")")
                    completion(.success(createdDocument))
                } else if task.isCancelled {
                    completion(.failure(AnalysisError.cancelled))
                } else {
                    completion(.failure(AnalysisError.documentCreation))
                }
                
                return nil
            })
    }
    
    func getSessionBlock(cancellationToken token: BFCancellationToken? = nil)
        -> ((BFTask<AnyObject>) -> Any?) {
            return {
                [weak self] (task: BFTask<AnyObject>?) -> Any! in
                guard let `self` = self else { return nil }
                
                if task?.error != nil {
                    return self.giniSDK.sessionManager.logIn()
                }
                return task?.result
            }
    }
    
    func fetchExtractions(for documents: [GINIDocument], completion: @escaping AnalysisCompletion) {
        self.giniSDK
            .documentTaskManager
            .getExtractionsFor(documents,
                               cancellationToken: nil)
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
                    
                    completion(.success((result)))
                } else {
                    let error = NSError(domain: "net.gini.error.", code: AnalysisError.unknown._code, userInfo: nil)
                    print("❌", finishedString, "this error: \(error)")
                    
                    completion(.failure(AnalysisError.unknown))
                }
                
                
                return nil
            }
    }
    
}
