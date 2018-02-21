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
    
    lazy var vc: MultipageReviewController = {
        let vc = MultipageReviewController(imageDocuments: self.imageDocuments)
        _ = vc.view
        return vc
    }()
    
    lazy var imageDocuments: [GiniImageDocument] = [
        self.loadImageDocument(withName: "invoice"),
        self.loadImageDocument(withName: "invoice2"),
        self.loadImageDocument(withName: "invoice3")
    ]
    
    func testCollectionsItemsCount() {
        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 3,
                       "main collection items count should be 3")
        
        XCTAssertEqual(vc.pagesCollection.numberOfItems(inSection: 0), 3,
                       "pages collection items count should be 3")
    }
    
    func testMainCollectionCellContent() {
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

    }
    
    func testMainCollectionCellContentMode() {
        let firstCell = vc.collectionView(vc.mainCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewMainCollectionCell
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFit,
                       "Main collection cells image content mode should match the one passed in the initializer")
    }
    
    func testMainCollectionCellSize() {
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = vc.collectionView(vc.mainCollection,
                                         layout: vc.mainCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        XCTAssertEqual(cellSize, vc.mainCollection.frame.size,
                       "First cell image should match the one passed in the initializer")
    }
    
    func testMainCollectionInsets() {
        let collectionInsets = vc.collectionView(vc.mainCollection,
                                                 layout: vc.mainCollection.collectionViewLayout,
                                                 insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, .zero,
                       "Main collection insets should be zero")
    }
    
    func testPagesCollectionCellContent() {
        let firstCell = vc.collectionView(vc.pagesCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        let secondCell = vc.collectionView(vc.pagesCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewPagesCollectionCell
        let thirdCell = vc.collectionView(vc.pagesCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewPagesCollectionCell
        XCTAssertEqual(firstCell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.pageIndicatorLabel.text, "1",
                       "First cell indicator should match its position")
        XCTAssertEqual(secondCell?.documentImage.image, imageDocuments[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.pageIndicatorLabel.text, "2",
                       "Second cell indicator should match its position")
        XCTAssertEqual(thirdCell?.documentImage.image, imageDocuments[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.pageIndicatorLabel.text, "3",
                       "Third cell indicator should match its position")
    }
    
    func testPagesCollectionCellContentMode() {
        let firstCell = vc.collectionView(vc.pagesCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFill,
                       "Pages collection cells image content mode should match the one passed in the initializer")
    }
    
    func testPagesCollectionCellSize() {
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = vc.collectionView(vc.pagesCollection,
                                         layout: vc.pagesCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        let size = MultipageReviewPagesCollectionCell.size
        
        XCTAssertEqual(cellSize, size,
                       "Pages collection cells should have the value declared in the class")
    }
    
    func testPagesCollectionInsets() {
        let collectionInsets = vc.collectionView(vc.pagesCollection,
                                                 layout: vc.pagesCollection.collectionViewLayout,
                                                 insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, vc.pagesCollectionInsets,
                       "Main collection insets should be zero")
    }
    
    func testToolBarItemsOnInitialization() {
        guard let items = self.vc.toolBar.items else {
            assertionFailure("MultipageReviewController toolbar items are nil")
            return
        }
        XCTAssertEqual(items[0], self.vc.rotateButton,
                       "First toolbar item should be the rotateButton")
        XCTAssertEqual(items[2], self.vc.reorderButton,
                       "Third toolbar item should be the reorderButton")
        XCTAssertEqual(items[4], self.vc.deleteButton,
                       "Fifth toolbar item should be the deleteButton")
    }
    
    func testToolBarAndPagesCollectionContainerColors() {
        XCTAssertEqual(vc.toolBar.barTintColor, vc.pagesCollectionContainer.backgroundColor,
                       "toolbar and pages collection container background colors should match")
    }
    
    func testDatasourceOnDelete() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        (vc.deleteButton.customView as? UIButton)?.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 2,
                       "main collection items count should be 2")
        XCTAssertEqual(vc.pagesCollection.numberOfItems(inSection: 0), 2,
                       "pages collection items count should be 2")
    }
    
    func testCellReloadedOnReordering() {
        let expect = expectation(description: "Delayed reloading on reordering has finished")
        let currentIndexPath = IndexPath(row: 0, section: 0)
        let destinationIndexPath = IndexPath(row: 2, section: 0)
        var updatedImageDocument: [GiniImageDocument] = []
        
        vc.didUpdateDocuments = { updatedDocuments in
            updatedImageDocument = updatedDocuments
            expect.fulfill()
        }
        
        vc.collectionView(vc.pagesCollection, moveItemAt: currentIndexPath, to: destinationIndexPath)
        
        wait(for: [expect], timeout: 1)
        let firstCell = vc.collectionView(vc.pagesCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewPagesCollectionCell
        let secondCell = vc.collectionView(vc.pagesCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewPagesCollectionCell
        let thirdCell = vc.collectionView(vc.pagesCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewPagesCollectionCell
        
        XCTAssertEqual(firstCell?.documentImage.image, updatedImageDocument[0].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.pageIndicatorLabel.text, "1",
                       "First cell indicator should match its position")
        XCTAssertEqual(secondCell?.documentImage.image, updatedImageDocument[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.pageIndicatorLabel.text, "2",
                       "Second cell indicator should match its position")
        XCTAssertEqual(thirdCell?.documentImage.image, updatedImageDocument[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.pageIndicatorLabel.text, "3",
                       "Third cell indicator should match its position")
        
    }
}
