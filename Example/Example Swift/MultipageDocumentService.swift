//
//  MultipageDocumentsService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import UIKit
import Gini_iOS_SDK
import GiniVision

final class MultipageDocumentsService: ComponentAPIDocumentServiceProtocol {
    
    var giniSDK: GiniSDK
    var partialDocuments: [String: PartialDocumentInfo] = [:]
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    var pendingAnalysisHandler: ComponentAPIAnalysisCompletion?

    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping ComponentAPIAnalysisCompletion) {
        let partialDocumentsInfoSorted = partialDocuments
            .lazy
            .map { $0.value }
            .sorted()
            .map { $0.info }
            .filter { $0.documentUrl != nil}
        
        // When a PDF/QrCode document is imported the analysis screen is shown right away, and therefore the analysis
        // is triggered. There could be the case where the document hadn't been analyzed when this happens,
        // that's why a reference to the completion block has to be kept. Once the document is uploaded,
        // the completion block is called (see below).
        guard !partialDocumentsInfoSorted.isEmpty else {
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
    
    func delete(_ document: GiniVisionDocument) {
        if let index = partialDocuments.index(forKey: document.id) {
            if let partialDocumentId = partialDocuments[document.id]?
                .info
                .documentId {
                deletePartialDocument(with: partialDocumentId)
            }
            partialDocuments.remove(at: index)
        }
    }
    
    private func deletePartialDocument(with id: String) {
        giniSDK.sessionManager
            .getSession()
            .continueWith(block: sessionBlock(cancellationToken: nil))
            .continueOnSuccessWith(block: { [weak self] _ in
                self?.giniSDK.documentTaskManager.deletePartialDocument(withId: id,
                                                                        cancellationToken: nil)
            })
            .continueWith(block: { task in
                if task.isCancelled || task.error != nil {
                    print("❌ Error deleting partial document with id:", id)
                } else {
                    print("🗑 Deleted partial document with id:", id)
                }
                
                return nil
            })
    }
    
    func update(_ imageDocument: GiniImageDocument) {
        partialDocuments[imageDocument.id]?.info.rotationDelta = Int32(imageDocument.rotationDelta)
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        for index in 0..<documents.count {
            let id = documents[index].id
            partialDocuments[id]?.order = index
        }
        
    }
    
    func upload(_ document: GiniVisionDocument,
                completion: ComponentAPIUploadDocumentCompletion?) {
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
