//
//  PageStatusViewTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class PageStatusViewTests: XCTestCase {
    
    var statusView: PageStatusView!
    
    override func setUp() {
        super.setUp()
        statusView = PageStatusView(frame: .zero)
    }
    
    func testLoadingStatus() {
        statusView.update(to: .loading)
        XCTAssertNil(statusView.icon.image, "icon image should be nil when it is loading")
        XCTAssertTrue(statusView.loadingIndicator.isAnimating, "loading indicator should be animating when loading")
    }
    
    func testSuccessStatus() {
        statusView.update(to: .success)
        XCTAssertEqual(statusView.backgroundColor, Colors.Gini.springGreen, "background color should be green")
        XCTAssertNotNil(statusView.icon.image, "icon image should not be nil when it is loading")
        XCTAssertFalse(statusView.loadingIndicator.isAnimating, "loading indicator should not be animating when loading")
    }
    
    func testFailureStatus() {
        statusView.update(to: .failure)
        XCTAssertEqual(statusView.backgroundColor, Colors.Gini.crimson, "background color should be red")
        XCTAssertNotNil(statusView.icon.image, "icon image should not be nil when it is loading")
        XCTAssertFalse(statusView.loadingIndicator.isAnimating, "loading indicator should not be animating when loading")
    }
    
}