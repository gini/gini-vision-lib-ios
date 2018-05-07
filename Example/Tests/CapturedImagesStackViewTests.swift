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
        capturedImagesStackView.replaceStackImages(with: [])
        
        XCTAssertTrue(capturedImagesStackView.isHidden,
                      "capturedImagesStackView should be hidden when there are no images")
        
    }
    
    func testCaptureStackWhenOneImageCaptured() {
        let images = [loadImage(withName: "invoice.jpg")!]
        
        capturedImagesStackView.replaceStackImages(with: images)
        
        XCTAssertFalse(capturedImagesStackView.isHidden,
                      "capturedImagesStackView should not be hidden when it is filled")
        XCTAssertTrue(capturedImagesStackView.thumbnailStackBackgroundView.isHidden,
                      "thumbnailStackBackgroundView should be hidden when there is only 1 image")
        XCTAssertEqual(capturedImagesStackView.thumbnailButton.image(for: .normal), images[0],
                       "thumbnailButton image should match last image in array")
        
    }
    
    func testCaptureStackWhenTwoImageCaptured() {
        let images = [loadImage(withName: "invoice.jpg")!,
                      loadImage(withName: "invoice2.jpg")!]
        capturedImagesStackView.replaceStackImages(with: images)
        
        XCTAssertFalse(capturedImagesStackView.isHidden,
                       "capturedImagesStackView should not be hidden when it is filled")
        XCTAssertFalse(capturedImagesStackView.thumbnailStackBackgroundView.isHidden,
                       "thumbnailStackBackgroundView should not be hidden when there are 2 images")
        XCTAssertEqual(capturedImagesStackView.thumbnailButton.image(for: .normal), images[1],
                       "thumbnailButton image should match last image in array")

    }
    
}
