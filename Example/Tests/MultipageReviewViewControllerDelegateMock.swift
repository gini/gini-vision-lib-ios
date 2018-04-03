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
    
    func multipageReview(_ controller: MultipageReviewViewController,
                         didUpdateDocuments documents: [GiniImageDocument]) {
        updatedDocuments = documents
    }
}