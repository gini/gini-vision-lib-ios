//
//  SingleDocumentService.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/29/18.
//

import Foundation
import Gini_iOS_SDK

final class SingleDocumentService: DocumentServiceProtocol {

    var giniSDK: GiniSDK
    var isAnalyzing = false
    
    var document: GINIDocument?
    var pendingAnalysisHandler: AnalysisCompletion?
    
    init(sdk: GiniSDK) {
        self.giniSDK = sdk
    }
    
    func startAnalysis(completion: @escaping AnalysisCompletion) {
        guard let document = document else {
            pendingAnalysisHandler = completion
            return
        }
        
        fetchExtractions(for: [document], completion: completion)
    }
    
    func cancelAnalysis() {
        document = nil
        isAnalyzing = false
    }
    
    func upload(document: GiniVisionDocument) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        
        createDocument(from: document, fileName: "fileName", cancellationToken: token) { result in
            switch result {
            case .success(let document):
                self.document = document
                if let handler = self.pendingAnalysisHandler {
                    self.startAnalysis(completion: handler)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func sendFeedback(withResults results: [String: Extraction]) {
        
    }
    
}
