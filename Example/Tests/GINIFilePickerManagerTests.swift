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
    
    func testSourceTypeInitializationForImagePicker() {
        let sourceType = filePickerManager.imagePicker.sourceType
        XCTAssert(sourceType == .photoLibrary, "source type should always be photo library, not camera")
    }
    
}
