//
//  DocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

final class CompositeDocumentService: DocumentServiceProtocol {
    
    var giniSDK: GiniSDK
    var isAnalyzing = false
    var partialDocuments: [String: PartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    
    func cancelAnalysis() {
        partialDocuments.removeAll()
        isAnalyzing = false
    }
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfo = partialDocuments.map { $0.value }
        self.fetchExtractions(for: partialDocumentsInfo, completion: completion)
    }
    
    func upload(document: GiniVisionDocument,
                withParameters parameters: [String: Any],
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        
        createDocument(from: document, withParameters: parameters, fileName: "", cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id] = PartialDocumentInfo(document: createdDocument.links.document,
                                                                         additionalParameters: parameters)
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
