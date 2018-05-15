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
    var pendingAnalysisHandler: AnalysisCompletion?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
            .filter { $0.documentUrl != nil}
        
        // When a PDF/QrCode document is imported the analysis screen is shown right away, and therefore the analysis
        // is triggered. There could be the case where the document hadn't been analyzed when this happens,
        // that's why a reference to the completion block ahs to be kept. Once the document is uploaded,
        // the completion block is called (see below).
        guard partialDocumentsInfoSorted.isNotEmpty else {
            pendingAnalysisHandler = completion
            return
        }
        
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
    
    func update(imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = Int32(imageDocument.rotationDelta)
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        for index in 0..<documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }

    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        self.partialDocuments[document.id] =
            PartialDocumentInfo(info: (GINIPartialDocumentInfo(documentUrl: nil, rotationDelta: 0)),
                                order: self.partialDocuments.count)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"

        createDocument(from: document, fileName: fileName, cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments[document.id]?.info.documentUrl = createdDocument.links.document
                
                if let handler = self.pendingAnalysisHandler {
                    self.startAnalysis(completion: handler)
                    self.pendingAnalysisHandler = nil
                }
                
                completion?(.success(createdDocument))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
