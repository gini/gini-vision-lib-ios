//
//  SingleDocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini_iOS_SDK

final class SingleDocumentService: DocumentServiceProtocol {

    var compositeDocument: GINIDocument?
    var giniSDK: GiniSDK
    var isAnalyzing = false
    
    var partialDocumentInfo: PartialDocumentInfo?
    var pendingAnalysisHandler: AnalysisCompletion?
    
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
        compositeDocument = nil
        partialDocumentInfo = nil
        isAnalyzing = false
    }
    
    func remove(document: GiniVisionDocument) {
        cancelAnalysis()
    }
    
    func update(parameters: [String: Any], for document: GiniVisionDocument) {
        partialDocumentInfo?.updateAdditionalParameters(with: parameters)
    }
    
    func upload(document: GiniVisionDocument,
                completion: UploadDocumentCompletion?) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        partialDocumentInfo = PartialDocumentInfo()
        
        createDocument(from: document,
                       fileName: "fileName",
                       cancellationToken: token) { result in
            switch result {
            case .success(let document):
                self.partialDocumentInfo?.documentUrl = document.links.document
                
                if let handler = self.pendingAnalysisHandler {
                    self.startAnalysis(completion: handler)
                }
            case .failure(let error):
                print("Partial document creation error: ", error)
            }
        }
    }
}
