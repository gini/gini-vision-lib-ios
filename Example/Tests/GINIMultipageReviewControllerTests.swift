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
        
        let firstCell = vc.collectionView(vc.mainCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewMainCollectionCell
        let secondCell = vc.collectionView(vc.mainCollection,
                                          cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewMainCollectionCell
        let thirdCell = vc.collectionView(vc.mainCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewMainCollectionCell
        XCTAssertEqual(firstCell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.documentImage.image, imageDocuments[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.documentImage.image, imageDocuments[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFit,
                       "First cell content mode should match the one passed in the initializer")
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
    
    func testBottomCollectionCellContent() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        let firstCell = vc.collectionView(vc.bottomCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewBottomCollectionCell
        let secondCell = vc.collectionView(vc.bottomCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewBottomCollectionCell
        let thirdCell = vc.collectionView(vc.bottomCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewBottomCollectionCell
        XCTAssertEqual(firstCell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.documentImage.image, imageDocuments[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.documentImage.image, imageDocuments[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFill,
                       "First cell content mode should match the one passed in the initializer")
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
    
    func testToolBarAndBottomCollectionContainerColors() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        XCTAssertEqual(vc.toolBar.barTintColor, vc.bottomCollectionContainer.backgroundColor,
                       "toolbar and bottom collection container background colors should match")
    }
}
