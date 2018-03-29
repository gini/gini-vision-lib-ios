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
        let uploadedDocuments = partialDocuments.flatMap { $0.document}
        
        fetchExtractions(for: uploadedDocuments, completion: completion)
    }
    
    func upload(document: GiniVisionDocument) {
        let cancellationTokenSource = BFCancellationTokenSource()
        let token = cancellationTokenSource.token
        partialDocuments.append((nil, cancellationTokenSource.token))
        
        createDocument(from: document, fileName: "", cancellationToken: token) { result in
            switch result {
            case .success(let createdDocument):
                self.partialDocuments.append((createdDocument, token))
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func sendFeedback(withResults results: [String: Extraction]) {
        //        _ = giniSDK?.sessionManager.getSession()
        //            .continueWith(block: getSessionBlock())
        //            .continueOnSuccessWith(block: { _ in return self.document?.getExtractions() })
        //            .continueOnSuccessWith(block: { (task: BFTask?) in
        //                if let extractions = task?.result as? NSMutableDictionary {
        //                    results.forEach { result in
        //                        extractions[result.key] = result.value
        //                    }
        //
        //                    return self.giniSDK?
        //                        .documentTaskManager?
        //                        .update(self.document)
        //                }
        //
        //                return nil
        //            })
        //            .continueOnSuccessWith(block: { _ in return self.document?.getExtractions() })
        //            .continueWith(block: { (task: BFTask?) in
        //                guard let extractions = task?.result as? NSMutableDictionary else {
        //                    print("Error sending feedback for document with id: ",
        //                          String(describing: self.document?.documentId))
        //                    return nil
        //                }
        //
        //                print("🚀 Feedback sent with \(extractions.count) extractions")
        //                return nil
        //            })
    }
}
