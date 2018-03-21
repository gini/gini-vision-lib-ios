//
//  GINIVisionDocumentTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 8/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

class GINIVisionDocumentTests: XCTestCase {
    
    var filePickerManager: DocumentPickerCoordinator {
        return DocumentPickerCoordinator()
    }
    
    func testExcedeedMaxFileSize() {
        let higherThan10MBData = generateFakeData(megaBytes: 12)
        
        let fakeDocument = GiniPDFDocument(data: higherThan10MBData)
        
        XCTAssertThrowsError(try fakeDocument.validate(),
                             "Files with a size lower than 10MB should be valid") { error in
            XCTAssert(error as? DocumentValidationError == DocumentValidationError.exceededMaxFileSize,
                      "should indicate that max file size has been exceeded")
        }
    }
    
    func testNotExcedeedMaxFileSize() {
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)
        
        let fakeDocument = GiniPDFDocument(data: lowerThanOrEqualTo10MBData)

        XCTAssertThrowsError(try fakeDocument.validate(),
                             "Files with a size greater than 10MB should not be valid") { error in
            XCTAssert(error as? DocumentValidationError != DocumentValidationError.exceededMaxFileSize,
                      "should indicate that max file size has been exceeded")
        }
    }
    
    func testImageValidation() {
        let image = loadImage(withName: "tabBarIconHelp")
        let imageDocument = GiniImageDocument(data: UIImagePNGRepresentation(image!)!, imageSource: .camera)
        
        XCTAssertNoThrow(try imageDocument.validate(), "Valid images should validate without throwing an exception")
    }
    
    fileprivate func generateFakeData(megaBytes lengthInMB: Int) -> Data {
        let length = lengthInMB * 1000000
        return Data(count: length)
    }
}
