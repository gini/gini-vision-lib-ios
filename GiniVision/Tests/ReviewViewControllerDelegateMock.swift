//
//  ReviewViewControllerDelegateMock.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 5/11/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import GiniVision

final class ReviewViewControllerDelegateMock: ReviewViewControllerDelegate {
    
    var isDocumentReviewed = false
    
    func review(_ viewController: ReviewViewController, didReview document: GiniVisionDocument) {
        isDocumentReviewed = true
    }
}
