//
//  MultipageDocumentsService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

final class MultipageDocumentsService: DocumentServiceProtocol {
    
    var giniSDK: GiniSDK
    var partialDocuments: [String: PartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments.map { $0.value }.sorted()
        self.fetchExtractions(for: partialDocumentsInfoSorted, completion: completion)
    }
    
    func cancelAnalysis() {
        if let compositeDocument = compositeDocument {
            deleteCompositeDocument(withId: compositeDocument.documentId)
        }
        
        compositeDocument = nil
    }
    
    func remove(document: GiniVisionDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let partialDocumentId = partialDocuments[document.id]?
                .documentId {
                deletePartialDocument(withId: partialDocumentId)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    func update(parameters: [String: Any], for document: GiniVisionDocument) {
        self.partialDocuments[document.id]?.updateAdditionalParameters(with: parameters)
    }
    
    func orderDocuments(givenVisionDocumentIds ids: [String]) {
        for index in 0..<ids.count {
            let id = ids[index]
            partialDocuments[id]?.order = index
        }
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        self.partialDocuments[document.id] = PartialDocumentInfo()
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document, fileName: fileName, cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.documentUrl = createdDocument.links.document
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
