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
    
    let helpMenuViewController: HelpMenuViewController = HelpMenuViewController()
    lazy var mockedItems: [(text: String,id: Int)] = {
        return [
            ("First item", 1),
            ("Second item", 2),
            ("Third item", 3)
        ]
    }()
    
    override func setUp() {
        super.setUp()
        _ = helpMenuViewController.view
    }
    
    func testNumberOfSections() {
        let numberOfSections = helpMenuViewController.tableView.numberOfSections
        
        XCTAssertEqual(numberOfSections, 1, "The number of sections of the table should be always 1")
    }
    
    func testItemsCount() {
        let itemsCount = helpMenuViewController.items.count
        
        let tableRowsCount = helpMenuViewController.tableView.numberOfRows(inSection: 0)
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testItemsCountForMockedSection() {
        helpMenuViewController.items = mockedItems
        helpMenuViewController.tableView.reloadData()
        
        let tableRowsCount = helpMenuViewController.tableView.numberOfRows(inSection: 0)
        
        XCTAssertEqual(3, tableRowsCount, "the number of items should be equal to mocked items declared above")
    }
    
    func testCellContent() {
        let indexPath = IndexPath(row: 0, section: 0)
        let itemText = helpMenuViewController.items[indexPath.row].text
        let cellBackgroundColor = UIColor.white
        let cellAccesoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        let cell = helpMenuViewController.tableView(helpMenuViewController.tableView, cellForRowAt: indexPath)
        
        XCTAssertEqual(itemText, cell.textLabel?.text, "cell text in the first row should be the same as the first item text")
        XCTAssertEqual(cellBackgroundColor, cell.backgroundColor, "cell background color should always be white")
        XCTAssertEqual(cellAccesoryType, cell.accessoryType, "cell accesory type should be and a disclosure indicator")
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
