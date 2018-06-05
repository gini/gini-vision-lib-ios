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
    
    init(sdk: GiniSDK) {
        giniSDK = sdk
    }
    
    func cancelAnalysis() {
        
    }
    
    func delete(_ document: GiniVisionDocument) {
        
    }
    
    func update(_ imageDocument: GiniImageDocument) {
        
    }
    
    func startAnalysis(completion: @escaping ((CompletionResult<[String : Extraction]>) -> Void)) {
        
    }
    
    func upload(_ document: GiniVisionDocument, completion: ((CompletionResult<GINIDocument>) -> Void)?) {
        
    }

}
