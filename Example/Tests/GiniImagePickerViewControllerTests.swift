//
//  GiniImagePickerViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GiniImagePickerViewControllerTests: XCTestCase {
    
    let vc = GiniImagePickerViewController(galleryManager: GiniGalleryImageManagerMock(),
                                           giniConfiguration: GiniConfiguration.sharedConfiguration)
    
    override func setUp() {
        super.setUp()
        _ = vc.view
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(vc.collectionView.numberOfSections, 1, "There should be only one section")
    }
    
    func testNumberOfItems() {
        XCTAssertEqual(vc.collectionView.numberOfItems(inSection: 0), 3, "There should be 3 images")
    }
    
    func testCollectionCellType() {
        XCTAssertNotNil(vc.collectionView(vc.collectionView,
                                          cellForItemAt: IndexPath(row:0, section:0)) as? GiniImagePickerCollectionViewCell,
                        "cell type should match GiniImagePickerCollectionViewCell")
    }
}
