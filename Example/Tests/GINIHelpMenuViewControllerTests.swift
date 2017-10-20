//
//  GINIHelpMenuViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GINIHelpMenuViewControllerTests: XCTestCase {
    
    let helpMenuViewController: HelpMenuViewController = HelpMenuViewController(style: .plain)
    
    override func setUp() {
        super.setUp()
        _ = helpMenuViewController.view
    }
    
    func testNumberOfSections() {
        let numberOfSections = helpMenuViewController.tableView.numberOfSections
        
        XCTAssertEqual(numberOfSections, 1, "The number of sections of the table should be always 1")
    }
    
    func testNumberOfRowsInSection0() {
        let itemsCount = helpMenuViewController.items.count
        
        let tableRowsCount = helpMenuViewController.tableView.numberOfRows(inSection: 0)
        
        XCTAssertEqual(itemsCount, tableRowsCount, "the number of rows should be equal to the datasource items count")
    }
    
    func testCellTextAtIndexPath() {
        let indexPath = IndexPath(row: 0, section: 0)
        let itemText = helpMenuViewController.items[indexPath.row].text
        
        let cellTextAtIndexPath = helpMenuViewController.tableView(helpMenuViewController.tableView, cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(itemText, cellTextAtIndexPath, "cell text in the first row should be the same as the first item text")
        
    }
    
    func testTableRowheight() {
        let tableRowHeight = helpMenuViewController.tableView.rowHeight
        
        XCTAssertEqual(tableRowHeight, helpMenuViewController.tableRowHeight, "table row height should be the one declared on the initialization")
    }
    
    func testNoViewControllerForUnknownID() {
        let unknownID = -1
        
        let viewController = helpMenuViewController.viewController(forRowWithId: unknownID)
        
        XCTAssertNil(viewController, "should be nil since none viewController on the tableview has that ID")
    }
    
}
