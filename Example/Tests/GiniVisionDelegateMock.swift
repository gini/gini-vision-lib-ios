//
//  GiniVisionDelegateMock.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 3/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class GiniVisionDelegateMock: GiniVisionDelegate {
    func didCapture(document: GiniVisionDocument, uploadDelegate: UploadDelegate) {
        
    }
    
    func didReview(documents: [GiniVisionDocument]) {
        
    }
    
    func didCancelCapturing() {
        
    }
    
    func didCancelReview(for document: GiniVisionDocument) {
        
    }
    
    func didCancelAnalysis() {
        
    }
    

    
    
}
