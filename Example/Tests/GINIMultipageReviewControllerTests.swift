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
        
        XCTAssertEqual(vc.bottomCollection.numberOfItems(inSection: 0), 3,
                       "bottom collection items count should be 3")
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
    
    func testMainCollectionInsets() {
        let collectionInsets = vc.collectionView(vc.mainCollection,
                                         layout: vc.mainCollection.collectionViewLayout,
                                         insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, .zero,
                       "Main collection insets should be zero")
    }
    
    func testBottomCollectionCellContent() {
        let firstCell = vc.collectionView(vc.bottomCollection,
                                          cellForItemAt: IndexPath(row: 0, section: 0)) as? MultipageReviewBottomCollectionCell
        let secondCell = vc.collectionView(vc.bottomCollection,
                                           cellForItemAt: IndexPath(row: 1, section: 0)) as? MultipageReviewBottomCollectionCell
        let thirdCell = vc.collectionView(vc.bottomCollection,
                                          cellForItemAt: IndexPath(row: 2, section: 0)) as? MultipageReviewBottomCollectionCell
        XCTAssertEqual(firstCell?.documentImage.image, imageDocuments[0].previewImage,
                       "First cell image should match the one passed in the initializer")
        XCTAssertEqual(firstCell?.pageIndicator.text, "1",
                       "First cell indicator should match its position")
        XCTAssertEqual(secondCell?.documentImage.image, imageDocuments[1].previewImage,
                       "Second cell image should match the one passed in the initializer")
        XCTAssertEqual(secondCell?.pageIndicator.text, "2",
                       "Second cell indicator should match its position")
        XCTAssertEqual(thirdCell?.documentImage.image, imageDocuments[2].previewImage,
                       "Third cell image should match the one passed in the initializer")
        XCTAssertEqual(thirdCell?.pageIndicator.text, "3",
                       "Third cell indicator should match its position")
        XCTAssertEqual(firstCell?.documentImage.contentMode, UIViewContentMode.scaleAspectFill,
                       "First cell content mode should match the one passed in the initializer")
    }
    
    func testBottomCollectionCellSize() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        let firstCellIndexPath = IndexPath(row: 0, section: 0)
        let cellSize = vc.collectionView(vc.bottomCollection,
                                         layout: vc.bottomCollection.collectionViewLayout,
                                         sizeForItemAt: firstCellIndexPath)
        
        let size = MultipageReviewBottomCollectionCell.portraitSize
        
        XCTAssertEqual(cellSize, size,
                       "Bottom collection cells should have the value declared in the class")
    }
    
    func testBottomCollectionInsets() {
        let collectionInsets = vc.collectionView(vc.bottomCollection,
                                                 layout: vc.bottomCollection.collectionViewLayout,
                                                 insetForSectionAt: 0)
        
        XCTAssertEqual(collectionInsets, vc.bottomCollectionInsets,
                       "Main collection insets should be zero")
    }
    
    func testToolBarItemsOnInitialization() {
        XCTAssertEqual(vc.toolBar.items![0], vc.rotateButton,
                       "First toolbar item should be the rotateButton")
        XCTAssertEqual(vc.toolBar.items![2], vc.reorderButton,
                       "Third toolbar item should be the rotateButton")
        XCTAssertEqual(vc.toolBar.items![4], vc.deleteButton,
                       "Fifth toolbar item should be the rotateButton")
    }
    
    func testToolBarAndBottomCollectionContainerColors() {
        XCTAssertEqual(vc.toolBar.barTintColor, vc.bottomCollectionContainer.backgroundColor,
                       "toolbar and bottom collection container background colors should match")
    }
    
    func testDatasourceOnDelete() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        
        (vc.deleteButton.customView as? UIButton)?.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(vc.mainCollection.numberOfItems(inSection: 0), 2,
                       "main collection items count should be 2")
        XCTAssertEqual(vc.bottomCollection.numberOfItems(inSection: 0), 2,
                       "bottom collection items count should be 2")
    }
}
