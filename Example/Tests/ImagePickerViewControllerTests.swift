//
//  ImagePickerViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class ImagePickerViewControllerTests: XCTestCase {
    
    let galleryManager = GalleryManagerMock()
    lazy var currentAlbum = self.galleryManager.albums[0]
    
    lazy var vc = ImagePickerViewController(album: self.currentAlbum,
                                            galleryManager: GalleryManagerMock(),
                                            giniConfiguration: GiniConfiguration.sharedConfiguration)
    
    override func setUp() {
        super.setUp()
        _ = vc.view
    }
    
    func testViewControllerTitle() {
        let title = currentAlbum.title
        XCTAssertEqual(title, vc.title, "view controller title should match the album title")
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(vc.collectionView.numberOfSections, 1, "There should be only one section")
    }
    
    func testNumberOfItems() {
        XCTAssertEqual(vc.collectionView.numberOfItems(inSection: 0), 1,
                       "There should be only 1 image in the first album")
    }
    
    func testCollectionCellType() {
        XCTAssertNotNil(vc.collectionView(vc.collectionView,
                                          cellForItemAt: IndexPath(row:0, section:0)) as? ImagePickerCollectionViewCell,
                        "cell type should match GiniImagePickerCollectionViewCell")
    }

    func testCollectionCellSelection() {
        let delegate = ImagePickerViewControllerDelegateMock()
        vc.delegate = delegate
        let selectedCellIndex = IndexPath(row: 0, section: 0)
        let selectedCellIndex2 = IndexPath(row: 1, section: 0)

        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex)
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex2)
        
        XCTAssertEqual(delegate.selectedIndexes.count, 2,
                       "the selected indexes count should match thet ones delivered to the delegate")
    }
    
    func testCollectionCellDeselection() {
        let delegate = ImagePickerViewControllerDelegateMock()
        vc.delegate = delegate
        let selectedCellIndex = IndexPath(row: 0, section: 0)
        let selectedCellIndex2 = IndexPath(row: 1, section: 0)
        
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex)
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex2)
        vc.collectionView(vc.collectionView, didDeselectItemAt: selectedCellIndex2)
        
        XCTAssertEqual(delegate.selectedIndexes.count, 1,
                       "the selected indexes count should match thet ones delivered to the delegate")
    }
}
