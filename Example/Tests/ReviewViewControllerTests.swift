//
//  ReviewViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 5/11/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class ReviewViewControllerTests: XCTestCase {
    
    var reviewViewController: ReviewViewController!
    var reviewViewControllerDelegateMock: ReviewViewControllerDelegateMock!
    
    func testDidReviewOnRotationWithDelegate() {
        let document = loadImageDocument(withName: "invoice")
        reviewViewController = ReviewViewController(document: document, giniConfiguration: GiniConfiguration())
        _ = reviewViewController.view
        
        reviewViewControllerDelegateMock = ReviewViewControllerDelegateMock()
        reviewViewController.delegate = reviewViewControllerDelegateMock
        reviewViewController.rotateButton.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(reviewViewControllerDelegateMock.isDocumentReviewed,
                      "after tapping rotate button the document should have been modified and therefore the delegate" +
                      "should be notified")
    }
    
    func testDidReviewOnRotationWithBlocks() {
        let document = loadImageDocument(withName: "invoice")
        let expect = expectation(description: "success block is triggered after rotate image")
        reviewViewController = ReviewViewController(document, successBlock: { _ in
            expect.fulfill()
        }, failureBlock: { _ in})
        _ = reviewViewController.view
        reviewViewController.rotateButton.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
