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
    
    func testNavBarItemsOnOrderButtonInteraction() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        XCTAssertEqual(vc.navigationItem.leftBarButtonItem, vc.doneButton,
                       "Done button should be the only one on the left")
        XCTAssertNil(vc.navigationItem.rightBarButtonItems,
                     "Right bar buttons should be nil on initialization")
        
        vc.orderingButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(vc.navigationItem.leftBarButtonItem, vc.moveLeftButton,
                       "Move left button should be the only one on the left")
        XCTAssertEqual(vc.navigationItem.rightBarButtonItem, vc.moveRightButton,
                     "Move left button should be the only one on the left")
        
        vc.orderingButton.sendActions(for: .touchUpInside)

        XCTAssertEqual(vc.navigationItem.leftBarButtonItem, vc.doneButton,
                       "Done button should be the only one on the left")
        XCTAssertNil(vc.navigationItem.rightBarButtonItems,
                     "Right bar buttons should be nil on initialization")
    }

    func testDataSourceChangeWhenMovingLeft() {
        let vc = MultipageReviewController(imageDocuments: imageDocuments)
        _ = vc.view
        
        vc.orderingButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(vc.moveLeftButton.isEnabled,
                       "Move left button should be disabled after initialization")
        
        let indexPath = IndexPath(row: 1, section: 0)
        vc.mainCollection.selectItem(at: indexPath,
                                     animated: true,
                                     scrollPosition: .centeredHorizontally)
        
        let currentItemCellInMainCollection = vc.mainCollection.cellForItem(at: indexPath) as? MultipageReviewCollectionCell
        let currentItemCellInBottomCollection = vc.bottomCollection.cellForItem(at: indexPath) as? MultipageReviewCollectionCell

        vc.moveLeft()
        
        let nextIndexPath = IndexPath(row: 0, section: 0)
        let movedItemCellInMainCollection = vc.mainCollection.cellForItem(at: nextIndexPath) as? MultipageReviewCollectionCell
        let movedtItemCellInBottomCollection = vc.bottomCollection.cellForItem(at: nextIndexPath) as? MultipageReviewCollectionCell

        XCTAssertEqual(currentItemCellInMainCollection?.documentImage.image,
                       movedItemCellInMainCollection?.documentImage.image,
                       "image item should match the same item in previous position")
    }
}
