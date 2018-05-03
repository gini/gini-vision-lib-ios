//
//  MultipageDocumentsService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK

typealias GiniVisionDocumentId = String

final class MultipageDocumentsService: DocumentServiceProtocol {
    
    var giniSDK: GiniSDK
    var partialDocuments: [GiniVisionDocumentId: GINIPartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments.map { $0.value }
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
                .documentId {
                deletePartialDocument(withId: partialDocumentId)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.rotationDelta = Int32(imageDocument.rotationDelta)
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        partialDocuments.sorted(like: documents)
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        self.partialDocuments[document.id] = GINIPartialDocumentInfo(documentId: nil, rotationDelta: 0)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document, fileName: fileName, cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.documentId = createdDocument.links.document
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}

extension Dictionary where Value == GINIPartialDocumentInfo, Key == GiniVisionDocumentId {
    mutating func sorted(like sortedDocuments: [GiniVisionDocument]) {
        var sortedDict: [GiniVisionDocumentId: GINIPartialDocumentInfo] = [:]
        for document in sortedDocuments {
            sortedDict[document.id] = self[document.id]
        }
        
        self = sortedDict
    }
}
