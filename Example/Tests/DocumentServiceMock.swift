//
//  DocumentServiceMock.swift
//  Example Swift
//
//  Created by Enrique del Pozo Gómez on 6/5/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import Gini_iOS_SDK
@testable import GiniVision
@testable import Example_Swift


final class DocumentServiceMock: ComponentAPIDocumentServiceProtocol {

    var giniSDK: GiniSDK
    var compositeDocument: GINIDocument?
    var analysisCancellationToken: BFCancellationTokenSource?
    
    init(sdk: GiniSDK, documentMetadata: GINIDocumentMetadata?) {
        self.giniSDK = sdk
    }
    
    func cancelAnalysis() {
        
    }
    
    func remove(document: GiniVisionDocument) {
        
    }
    
    func resetToInitialState() {
        
    }
    
    func sendFeedback(with: [String: Extraction]) {
        
    }
    
    func startAnalysis(completion: @escaping ComponentAPIAnalysisCompletion) {
        
    }
    
    func sortDocuments(withSameOrderAs documents: [GiniVisionDocument]) {
        
    }
    
    func upload(document: GiniVisionDocument, completion: ComponentAPIUploadDocumentCompletion?) {
        
    }
    
    func update(imageDocument: GiniImageDocument) {
        
    }

}

extension DocumentServiceMock {
    convenience init() {
        self.init(sdk: GiniSDK(), documentMetadata: nil)
    }
}
