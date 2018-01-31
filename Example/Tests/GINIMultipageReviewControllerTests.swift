//
//  GINIMultipageReviewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GINIMultipageReviewControllerTests: XCTestCase {
   
    lazy var imageDocuments: [GiniImageDocument] = [
        self.loadImageDocument(withName: "invoice"),
        self.loadImageDocument(withName: "invoice2"),
        self.loadImageDocument(withName: "invoice3")
    ]
    
    func testCollectionsItemsCount() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 3,
                       "main collection items count should be 3")
        
        XCTAssertEqual(vc.bottomCollection.numberOfItems(inSection: 0), 3,
                       "bottom collection items count should be 3")
    }
    
    func testMainCollectionCellContent() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cell = vc.collectionView(vc.mainCollection,
                                     cellForItemAt: firstCellIndexPath) as? MultipageReviewCollectionCell
        
        XCTAssertEqual(cell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(cell?.documentImage.contentMode, UIViewContentMode.scaleAspectFit,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testMainCollectionCellSize() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = vc.collectionView(vc.mainCollection,
                                     layout: vc.mainCollection.collectionViewLayout,
                                     sizeForItemAt: firstCellIndexPath)
        
        XCTAssertEqual(cellSize, vc.mainCollection.frame.size,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testNavBarItemsOnInitialization() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        XCTAssertEqual(vc.navigationItem.leftBarButtonItem, vc.doneButton,
                       "Done button should be the only one on the left")
        XCTAssertNil(vc.navigationItem.rightBarButtonItems,
                     "Right bar buttons should be nil on initialization")
    }
    
    func testToolBarItemsOnInitialization() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        XCTAssertEqual(vc.toolBar.items![0], vc.rotateButton,
                       "First toolbar item should be the rotateButton")
        XCTAssertEqual(vc.toolBar.items![2], vc.orderButton,
                       "Third toolbar item should be the rotateButton")
        XCTAssertEqual(vc.toolBar.items![4], vc.deleteButton,
                       "Fifth toolbar item should be the rotateButton")
    }
}
