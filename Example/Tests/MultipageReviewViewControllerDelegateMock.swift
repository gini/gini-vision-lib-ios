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
                         didSelect errorAction: NoticeActionType,
                         for documentRequest: DocumentRequest) {
        
    }
    
    func multipageReviewDidTapAddImage(_ controller: MultipageReviewViewController) {
        
    }
    
    var updatedDocuments: [DocumentRequest] = []

    func multipageReview(_ controller: MultipageReviewViewController, didReorder documentRequests: [DocumentRequest]) {
        updatedDocuments = documentRequests
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didDelete documentRequests: DocumentRequest) {
        
    }
    
    func multipageReview(_ controller: MultipageReviewViewController, didRotate documentRequests: DocumentRequest) {
        
    }
}
