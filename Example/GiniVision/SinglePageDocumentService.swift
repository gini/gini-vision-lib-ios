//
//  SinglePageDocumentsService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini_iOS_SDK
import GiniVision

final class SinglePageDocumentsService: DocumentServiceProtocol {
    
    var compositeDocument: GINIDocument?
    var giniSDK: GiniSDK
    
    var partialDocumentInfo: GINIPartialDocumentInfo?
    var pendingAnalysisHandler: AnalysisCompletion?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        guard let partialDocumentInfo = partialDocumentInfo else {
            pendingAnalysisHandler = completion
            return
        }
        
        fetchExtractions(for: [partialDocumentInfo], completion: completion)
    }
    
    func cancelAnalysis() {
        if let compositeId = compositeDocument?.documentId {
            deleteCompositeDocument(withId: compositeId)
        }
        
        compositeDocument = nil
        partialDocumentInfo = nil
        pendingAnalysisHandler = nil
        
        analysisCancellationToken?.cancel()
        analysisCancellationToken = nil
    }
    
    func delete(_ document: GiniVisionDocument) {
        if let documentId = partialDocumentInfo?.documentId {
            deletePartialDocument(with: documentId)
        }
        cancelAnalysis()
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
                    print("❌ Error deleting composite document with id:", id)
                } else {
                    print("🗑 Deleted partial document with id:", id)
                }
                
                return nil
            })
    }
    
    func update(_ imageDocument: GiniImageDocument) {
        partialDocumentInfo?.rotationDelta = Int32(imageDocument.rotationDelta)
    }
    
    func upload(_ document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        partialDocumentInfo = GINIPartialDocumentInfo(documentUrl: nil, rotationDelta: 0)
        let fileName = "Partial-\(NSDate().timeIntervalSince1970)"
        
        createDocument(from: document,
                       fileName: fileName) { result in
                        switch result {
                        case .success(let document):
                            self.partialDocumentInfo?.documentUrl = document.links.document
                            
                            if let handler = self.pendingAnalysisHandler {
                                self.startAnalysis(completion: handler)
                            }
                        case .failure(let error):
                            print("❌ Partial document creation error: ", error)
                        }
        }
    }
}
