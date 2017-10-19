//
//  GINISupportedTypesViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GiniVision

class GINISupportedTypesViewControllerTests: XCTestCase {
    
    let supportedTypesViewController = SupportedTypesViewController(style: .plain)
    
    override func setUp() {
        super.setUp()
        _ = supportedTypesViewController.view
    }
    
    func testSectionsCount() {
        let sectionsCount = supportedTypesViewController.sections.count
        
        let tableSectionsCount = supportedTypesViewController.numberOfSections(in: supportedTypesViewController.tableView)
        
        XCTAssertEqual(sectionsCount, tableSectionsCount, "sections count and table sections count should be always equal")
    }
    
    func testSectionItemsCount() {
        let section = 0
        let section0ItemsCount = supportedTypesViewController.sections[section].items.count
        
        let tableSection0ItemsCount = supportedTypesViewController.tableView(supportedTypesViewController.tableView, numberOfRowsInSection: 0)
        
        XCTAssertEqual(section0ItemsCount, tableSection0ItemsCount, "items count inside section 0 and table section 0 items count should be always equal")
    }
    
    func testTableCellText() {
        let indexPath = IndexPath(row: 0, section: 0)
        let textForItem0AtSection0 = supportedTypesViewController.sections[indexPath.section].items[indexPath.row]
        
        let textForCellAtIndexPath = supportedTypesViewController.tableView(supportedTypesViewController.tableView, cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0AtSection0, "text for item 0 at section 0 should be equal to the one declared on initialization")
    }
    
    func testSectionHeaderHeight() {
        let sectionHeaderHeight = supportedTypesViewController.sectionHeight
        
        let tableSectionHeaderHeight = supportedTypesViewController.tableView.sectionHeaderHeight
        
        XCTAssertEqual(sectionHeaderHeight, tableSectionHeaderHeight, "table view section header height should be equal to the one declare on initialization")
    }
    
    func testRowHeight() {
        let rowHeight = supportedTypesViewController.rowHeight
        
        let tableRowHeight = supportedTypesViewController.tableView.rowHeight
        
        XCTAssertEqual(rowHeight, tableRowHeight, "table view row height should be equal to the one declare on initialization")
    }
    
    func testSectionTitle() {
        let section0Title = supportedTypesViewController.sections[0].title
        
        let tableSection0Title = supportedTypesViewController.tableView(supportedTypesViewController.tableView, titleForHeaderInSection: 0)
        
        XCTAssertEqual(section0Title, tableSection0Title, "table view section 0 title should be equal to the one declare on initialization")
    }
    
    func testRowSelectionDisabled() {
        let selectionState = supportedTypesViewController.tableView.allowsSelection
        
        XCTAssertFalse(selectionState, "table view cell selection should not be allowed")
    }
    
}
