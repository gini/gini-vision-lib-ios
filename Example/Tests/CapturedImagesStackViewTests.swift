//
//  CapturedImagesStackViewTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 5/7/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class CapturedImagesStackViewTests: XCTestCase {
    
    var capturedImagesStackView: CapturedImagesStackView!
    
    override func setUp() {
        super.setUp()
        capturedImagesStackView = CapturedImagesStackView(frame: .zero)
    }
    
    func testCaptureStackWhenNoImages() {
        capturedImagesStackView.updateStackStatus(to: .empty)
        
        XCTAssertTrue(capturedImagesStackView.isHidden,
                      "capturedImagesStackView should be hidden when there are no images")
        
    }
    
    func testCaptureStackWhenOneImageCaptured() {
        capturedImagesStackView.updateStackStatus(to: .filled(count: 1,
                                                              lastImage: loadImage(withName: "invoice.jpg")!))
        
        XCTAssertFalse(capturedImagesStackView.isHidden,
                      "capturedImagesStackView should not be hidden when it is filled")
        XCTAssertTrue(capturedImagesStackView.thumbnailStackBackgroundView.isHidden,
                      "thumbnailStackBackgroundView should be hidden when there is only 1 image")
        
    }
    
    func testCaptureStackWhenTwoImageCaptured() {
        capturedImagesStackView.updateStackStatus(to: .filled(count: 2,
                                                              lastImage: loadImage(withName: "invoice.jpg")!))
        XCTAssertFalse(capturedImagesStackView.isHidden,
                       "capturedImagesStackView should not be hidden when it is filled")
        XCTAssertFalse(capturedImagesStackView.thumbnailStackBackgroundView.isHidden,
                       "thumbnailStackBackgroundView should not be hidden when there are 2 images")

    }
    
}
