//
//  GINIFilePickerManagerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 8/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GiniVision


class GINIVisionDocumentTests: XCTestCase {
    
    var filePickerManager:FilePickerManager {
        return FilePickerManager()
    }
    
    func testExcedeedMaxFileSize() {
        // Given
        let higherThan10MBData = generateFakeData(megaBytes: 12)
        
        // When
        let fakeDocument = GiniPDFDocument(data: higherThan10MBData)
        
        // Then
        XCTAssertThrowsError(try fakeDocument.validate(), "should indicate that is not a valid document") { error in
            XCTAssert(error as? DocumentValidationError == DocumentValidationError.exceededMaxFileSize, "should indicate that max file size has been exceeded")
        }
    }
    
    func testNotExcedeedMaxFileSize() {
        // Given
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)
        
        // When
        let fakeDocument = GiniPDFDocument(data: lowerThanOrEqualTo10MBData)

        // Then
        XCTAssertThrowsError(try fakeDocument.validate(), "should indicate that is not a valid document") { error in
            XCTAssert(error as? DocumentValidationError != DocumentValidationError.exceededMaxFileSize, "should indicate that max file size has been exceeded")
        }
    }
    
    func testImageValidation() {
        // Given
        let testBundle = Bundle(for: type(of: self))
        let image = UIImage(named: "tabBarIconHelp", in: testBundle, compatibleWith: nil)

        // When
        let imageDocument = GiniImageDocument(data: UIImagePNGRepresentation(image!)!)
        
        // Then
        XCTAssertNoThrow(try imageDocument.validate(), "should not throw an exception given that it is a valid image")
    }
    
    fileprivate func generateFakeData(megaBytes lengthInMB:Int) -> Data {
        let length = lengthInMB * 1000000
        let bytes = [UInt32](repeating: 0, count: length).map { _ in arc4random() }
        return Data(bytes: bytes, count: length)
    }
}
