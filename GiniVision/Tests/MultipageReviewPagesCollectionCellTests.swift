//
//  MultipageReviewPagesCollectionCellTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 6/4/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class MultipageReviewPagesCollectionCellTests: XCTestCase {
    
    let cell: MultipageReviewPagesCollectionCell = MultipageReviewPagesCollectionCell(frame: .zero)

    func testPageIndicatorLabel() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipagePageIndicatorColor = .black

        cell.setUp(with: GiniVisionTestsHelper.loadImagePage(withName: "invoice"),
                   at: 0,
                   giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(cell.pageIndicatorLabel.textColor, giniConfiguration.multipagePageIndicatorColor,
                       "page cell indicator color should match the one specified in the configuration")
    }
    
    func testPageBottomContainerColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipagePageBackgroundColor = .red

        cell.setUp(with: GiniVisionTestsHelper.loadImagePage(withName: "invoice"),
                   at: 0,
                   giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(cell.bottomContainer.backgroundColor, giniConfiguration.multipagePageBackgroundColor,
                       "page cell background color should match the one specified in the configuration")
    }
    
    func testPageSelectedIndicatorColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipagePageSelectedIndicatorColor = .red
        
        cell.setUp(with: GiniVisionTestsHelper.loadImagePage(withName: "invoice"),
                   at: 0,
                   giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(cell.pageSelectedLine.backgroundColor, giniConfiguration.multipagePageSelectedIndicatorColor,
                       "selected line indicator background color should match the one specified in the configuration")
    }
    
    func testPageDraggableIconColor() {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.multipageDraggableIconColor = .red
        
        cell.setUp(with: GiniVisionTestsHelper.loadImagePage(withName: "invoice"),
                   at: 0,
                   giniConfiguration: giniConfiguration)
        
        XCTAssertEqual(cell.draggableIcon.tintColor, giniConfiguration.multipageDraggableIconColor,
                       "page draggable icon tint color should match the one specified in the configuration")
    }
    
}
