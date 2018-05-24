//
//  ImagePickerCollectionViewCellTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 5/24/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class ImagePickerCollectionViewCellTests: XCTestCase {
    
    let cell = ImagePickerCollectionViewCell(frame: .zero)

    func testCellCheckIndicatorBackgroundOnSelected() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.galleryPickerItemSelectedBackgroundCheckColor = .black
        
        cell.changeCheckCircle(to: true, giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(cell.checkImage.alpha, 1)
        XCTAssertEqual(cell.checkCircleBackground.backgroundColor,
                       giniConfiguration.galleryPickerItemSelectedBackgroundCheckColor)
    }
    
    func testCellCheckIndicatorBackgroundOnDeselected() {
        let giniConfiguration = GiniConfiguration()
        
        cell.changeCheckCircle(to: false, giniConfiguration: giniConfiguration)
        XCTAssertEqual(cell.checkImage.alpha, 0)
        XCTAssertEqual(cell.checkCircleBackground.backgroundColor,
                       UIColor.clear)

    }
}
