//
//  DocumentServiceProtocol.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini

typealias UploadDocumentCompletion = (Result<Document, GiniError>) -> Void
typealias AnalysisCompletion = (Result<[Extraction], GiniError>) -> Void

protocol DocumentServiceProtocol: class {
    
    var giniSDK: GiniSDK { get }
    var document: Document? { get set }
    var metadata: Document.Metadata? { get }
    var analysisCancellationToken: CancellationToken? { get set }
    
    func cancelAnalysis()
    func remove(document: GiniVisionDocument)
    func resetToInitialState()
    func sendFeedback(with updatedExtractions: [Extraction])
    func startAnalysis(completion: @escaping AnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument])
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}

extension DocumentServiceProtocol {
    
    func handleResults(completion: @escaping AnalysisCompletion) -> (CompletionResult<[Extraction]>){
        return { result in
            switch result {
            case .success(let extractions):
                print("✅ Finished analysis process with no errors")
                completion(.success(extractions))
            case .failure(let error):
                switch error {
                case .requestCancelled:
                    print("❌ Cancelled analysis process")
                default:
                    print("❌ Finished analysis process with error: \(error)")
                }
            }
        }
        
    }
}
