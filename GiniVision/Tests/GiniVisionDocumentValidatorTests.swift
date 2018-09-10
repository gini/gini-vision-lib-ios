//
//  GiniVisionDocumentValidatorTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GiniVisionDocumentValidatorTests: XCTestCase {
    
    let giniConfiguration = GiniConfiguration()
    
    func testExcedeedMaxFileSize() {
        let higherThan10MBData = generateFakeData(megaBytes: 12)
        
        let pdfDocument = GiniPDFDocument(data: higherThan10MBData)
        
        XCTAssertThrowsError(try GiniVisionDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size lower than 10MB should be valid") { error in
                                XCTAssert(error as? DocumentValidationError == .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }
    
    func testNotExcedeedMaxFileSize() {
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)
        
        let pdfDocument = GiniPDFDocument(data: lowerThanOrEqualTo10MBData)
        
        XCTAssertThrowsError(try GiniVisionDocumentValidator.validate(pdfDocument,
                                                                      withConfig: giniConfiguration),
                             "Files with a size greater than 10MB should not be valid") { error in
                                XCTAssert(error as? DocumentValidationError != .exceededMaxFileSize,
                                          "should indicate that max file size has been exceeded")
        }
    }
    
    func testImageValidation() {
        let image = GiniVisionTestsHelper.loadImage(with: "invoice")
        let imageDocument = GiniImageDocument(data: UIImageJPEGRepresentation(image!, 0.2)!, imageSource: .camera)
        
        XCTAssertNoThrow(try GiniVisionDocumentValidator.validate(imageDocument,
                                                                  withConfig: giniConfiguration),
                         "Valid images should validate without throwing an exception")
    }
    
    fileprivate func generateFakeData(megaBytes lengthInMB: Int) -> Data {
        let length = lengthInMB * 1000000
        return Data(count: length)
    }
    
}
