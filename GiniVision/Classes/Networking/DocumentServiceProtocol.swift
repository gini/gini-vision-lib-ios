//
//  DocumentServiceProtocol.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini_iOS_SDK
import Bolts


public typealias Extraction = GINIExtraction

typealias UploadDocumentCompletion = (Result<GINIDocument>) -> Void
typealias AnalysisCompletion = (Result<[String: Extraction]>) -> Void

protocol DocumentServiceProtocol: class {
    
    var giniSDK: GiniSDK { get }
    var document: GINIDocument? { get set }
    var metadata: GINIDocumentMetadata? { get }
    var analysisCancellationToken: BFCancellationTokenSource? { get set }

    init(sdk: GiniSDK, metadata: GINIDocumentMetadata?)
    func cancelAnalysis()
    func remove(document: GiniVisionDocument)
    func resetToInitialState()
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument])
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}

extension DocumentServiceProtocol {
    
    func getSession(with token: BFCancellationToken? = nil)
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
    
    func handleAnalysisResults(completion: @escaping AnalysisCompletion)
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
    
    func sendFeedback(with updatedExtractions: [String: Extraction]) {
        guard let document = document else { return }
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: getSession())
            .continueOnSuccessWith(block: { _ in
                return self.giniSDK
                    .documentTaskManager?
                    .update(document,
                            updatedExtractions: updatedExtractions,
                            cancellationToken: nil)
            })
            .continueWith(block: { (task: BFTask?) in
                if let error = task?.error {
                    let id = self.document?.documentId ?? ""
                    let message = "Error sending feedback for document with id: \(id) error: \(error)"
                    Log(message: message, event: .error)
                    
                    return nil
                }
                
                Log(message: "Feedback sent with \(updatedExtractions.count) extractions",
                    event: "🚀")
                
                return nil
            })
    }
}
