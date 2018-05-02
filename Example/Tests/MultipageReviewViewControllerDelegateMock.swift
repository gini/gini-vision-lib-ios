//
//  MultipageReviewViewControllerDelegateMock.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 3/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class MultipageReviewViewControllerDelegateMock: MultipageReviewViewControllerDelegate {
    
    var updatedDocuments: [GiniImageDocument] = []

    func multipageReview(_ controller: MultipageReviewViewController, didRotate document: GiniImageDocument) {
        
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didDelete document: GiniImageDocument) {
        
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didReorder documents: [GiniImageDocument]) {
        updatedDocuments = documents
    }

}
