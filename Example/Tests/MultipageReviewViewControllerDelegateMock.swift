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
    func multipageReview(_ viewController: MultipageReviewViewController,
                         didTapRetryUploadFor documentRequest: DocumentRequest) {
        
    }
    
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        
    }
    
    var updatedDocuments: [GiniVisionPage] = []

    func multipageReview(_ controller: MultipageReviewViewController, didReorder documentRequests: [GiniVisionPage]) {
        updatedDocuments = documentRequests
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didDelete documentRequests: GiniVisionPage) {
        
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didRotate documentRequests: GiniVisionPage) {
        
    }
}
