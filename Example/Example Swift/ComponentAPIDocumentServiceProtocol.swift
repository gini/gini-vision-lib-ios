//
//  ComponentAPIDocumentServiceProtocol.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini_iOS_SDK
import GiniVision

public typealias Extraction = GINIExtraction

enum CustomAnalysisError: GiniVisionError {
    case analysisFailed
    var message: String {
        switch self {
        case .analysisFailed:
            return NSLocalizedString("analysisFailedErrorMessage", comment: "analysis failed error message")
        }
    }
}

enum CompletionResult<T> {
    case success(T)
    case failure(Error)
}

typealias ComponentAPIUploadDocumentCompletion = (CompletionResult<GINIDocument>) -> Void
typealias ComponentAPIAnalysisCompletion = (CompletionResult<[String: Extraction]>) -> Void

protocol ComponentAPIDocumentServiceProtocol: class {
    
    var giniSDK: GiniSDK { get }
    var compositeDocument: GINIDocument? { get set }
    var analysisCancellationToken: BFCancellationTokenSource? { get set }
    
    init(sdk: GiniSDK)
    func cancelAnalysis()
    func remove(document: GiniVisionDocument)
    func resetToInitialState()
    func sendFeedback(with: [String: Extraction])
    func startAnalysis(completion: @escaping ComponentAPIAnalysisCompletion)
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument])
    func upload(document: GiniVisionDocument,
                completion: ComponentAPIUploadDocumentCompletion?)
    func update(imageDocument: GiniImageDocument)
}
