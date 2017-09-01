//
//  GINIFilePickerManagerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 8/30/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GiniVision


class GINIFilePickerManagerTests: XCTestCase {
    
    var filePickerManager:FilePickerManager {
        return FilePickerManager()
    }
    
    func testExcedeedMaxFileSize(){
        let higherThan10MBData = generateFakeData(megaBytes: 12)
        let fileSizeExceeded = filePickerManager.maxFileSizeExceeded(forData: higherThan10MBData)
        XCTAssertTrue(fileSizeExceeded, "should indicate that max file size has been exceeded")
    }
    
    func testNotExcedeedMaxFileSize(){
        let lowerThanOrEqualTo10MBData = generateFakeData(megaBytes: 10)
        let fileSizeExceeded = filePickerManager.maxFileSizeExceeded(forData: lowerThanOrEqualTo10MBData)
        XCTAssertFalse(fileSizeExceeded, "should indicate that max file size has not been exceeded")
    }
    
    fileprivate func generateFakeData(megaBytes lengthInMB:Int) -> Data{
        let length = lengthInMB * 1000000
        let bytes = [UInt32](repeating: 0, count: length).map { _ in arc4random() }
        return Data(bytes: bytes, count: length)
    }
}
