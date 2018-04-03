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
    var partialDocuments: [(document: GINIDocument?, token: BFCancellationToken?)] = []
    var compositeDocument: GINIDocument?
    
    func cancelAnalysis() {
        partialDocuments.removeAll()
        isAnalyzing = false
    }
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocuments = self.partialDocuments.flatMap { $0.document }
        
        self.fetchExtractions(for: partialDocuments, completion: completion)
    }
    
    func upload(document: GiniVisionDocument, completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        partialDocuments.append((nil, cancellationTokenSource.token))
        
        createDocument(from: document, fileName: "", cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments.append((createdDocument, token))
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
