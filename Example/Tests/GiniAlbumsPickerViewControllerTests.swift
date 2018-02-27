//
//  GiniAlbumsPickerViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

class GiniAlbumsPickerViewControllerTests: XCTestCase {
    
    let vc = AlbumsPickerViewController(galleryManager: GiniGalleryImageManagerMock())
    
    override func setUp() {
        super.setUp()
        _ = vc.view
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(vc.albumsTableView.numberOfSections, 1, "There should be only one section")
    }
    
    func testNumberOfItems() {
        XCTAssertEqual(vc.albumsTableView.numberOfRows(inSection: 0), 4, "There should be 4 albums")
    }
    
    func testCollectionCellType() {
        XCTAssertNotNil(vc.tableView(vc.albumsTableView,
                                     cellForRowAt: IndexPath(row:0, section:0)) as? UITableViewCell,
                        "cell type should match UITableViewCell")
    }
}
