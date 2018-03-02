//
//  GiniAlbumsPickerViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GiniAlbumsPickerViewControllerTests: XCTestCase {
    
    let galleryManager = GiniGalleryImageManagerMock()
    lazy var vc = AlbumsPickerViewController(galleryManager: self.galleryManager)
    
    override func setUp() {
        super.setUp()
        _ = vc.view
    }
    
    func testViewControllerTitle() {
        let title = NSLocalizedStringPreferred("ginivision.albums.title",
                                               comment: "title for the albums picker view controller")
        XCTAssertEqual(title, vc.title, "title should match the one provided in the Localizable file")
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(vc.albumsTableView.numberOfSections, 1, "There should be only one section")
    }
    
    func testNumberOfItems() {
        XCTAssertEqual(vc.albumsTableView.numberOfRows(inSection: 0), 3, "There should be 4 albums")
    }
    
    func testCollectionCellType() {
        XCTAssertNotNil(vc.tableView(vc.albumsTableView,
                                     cellForRowAt: IndexPath(row:0, section:0)) as? AlbumsPickerTableViewCell,
                        "cell type should match UITableViewCell")
    }
    
    func testTableCellHeight() {
        XCTAssertEqual(vc.tableView(vc.albumsTableView, heightForRowAt: IndexPath(row: 1, section:0)),
                       AlbumsPickerTableViewCell.height,
                       "table view cell heght should match AlbumsPickerTableViewCell height")
    }
    
    func testTableCellSelection() {
        let delegate = AlbumsPickerViewControllerDelegateMock()
        vc.delegate = delegate
        
        let selectedIndex = IndexPath(row: 0, section: 0)
        let selectedAlbum = galleryManager.albums[selectedIndex.row]
        vc.tableView(vc.albumsTableView, didSelectRowAt: selectedIndex)
        XCTAssertEqual(selectedAlbum, delegate.selectedAlbum,
                       "selected album should match the one delivered to the delegate")
    }
    
    func testTableCellContent() {
        let firstIndex = IndexPath(row: 0, section: 0)
        let secondIndex = IndexPath(row: 1, section: 0)
        
        let firstCell = vc.tableView(vc.albumsTableView, cellForRowAt: firstIndex) as? AlbumsPickerTableViewCell
        let secondCell = vc.tableView(vc.albumsTableView, cellForRowAt: secondIndex) as? AlbumsPickerTableViewCell
        
        XCTAssertEqual(firstCell?.albumTitleLabel.text, galleryManager.albums[firstIndex.row].title,
                       "album title label text should match the album title for the first cell")
        XCTAssertEqual(secondCell?.albumTitleLabel.text, galleryManager.albums[secondIndex.row].title,
                       "album title label text should match the album title for the second cell")
        XCTAssertEqual(firstCell?.albumSubTitleLabel.text, "\(galleryManager.albums[firstIndex.row].count)",
                       "album subtitle label text should match the album assets count for the first cell")
        XCTAssertEqual(secondCell?.albumSubTitleLabel.text, "\(galleryManager.albums[secondIndex.row].count)",
                       "album subtitle label text should match the album assets count for the second cell")

    }
}
