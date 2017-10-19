//
//  GINIsupportedFormatsViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GiniVision

class GINISupportedFormatsViewControllerTests: XCTestCase {
    
    let supportedFormatsViewController = SupportedFormatsViewController(style: .plain)
    
    override func setUp() {
        super.setUp()
        _ = supportedFormatsViewController.view
    }
    
    func testSectionsCount() {
        let sectionsCount = supportedFormatsViewController.sections.count
        
        let tableSectionsCount = supportedFormatsViewController.numberOfSections(in: supportedFormatsViewController.tableView)
        
        XCTAssertEqual(sectionsCount, tableSectionsCount, "sections count and table sections count should be always equal")
    }
    
    func testSectionItemsCount() {
        let section = 0
        let section0ItemsCount = supportedFormatsViewController.sections[section].items.count
        
        let tableSection0ItemsCount = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, numberOfRowsInSection: 0)
        
        XCTAssertEqual(section0ItemsCount, tableSection0ItemsCount, "items count inside section 0 and table section 0 items count should be always equal")
    }
    
    func testTableCellText() {
        let indexPath = IndexPath(row: 0, section: 0)
        let textForItem0AtSection0 = supportedFormatsViewController.sections[indexPath.section].items[indexPath.row]
        
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0AtSection0, "text for item 0 at section 0 should be equal to the one declared on initialization")
    }
    
    func testSectionHeaderHeight() {
        let sectionHeaderHeight = supportedFormatsViewController.sectionHeight
        
        let tableSectionHeaderHeight = supportedFormatsViewController.tableView.sectionHeaderHeight
        
        XCTAssertEqual(sectionHeaderHeight, tableSectionHeaderHeight, "table view section header height should be equal to the one declare on initialization")
    }
    
    func testRowHeight() {
        let rowHeight = supportedFormatsViewController.rowHeight
        
        let tableRowHeight = supportedFormatsViewController.tableView.rowHeight
        
        XCTAssertEqual(rowHeight, tableRowHeight, "table view row height should be equal to the one declare on initialization")
    }
    
    func testSectionTitle() {
        let section0Title = supportedFormatsViewController.sections[0].title
        
        let tableSection0Title = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, titleForHeaderInSection: 0)
        
        XCTAssertEqual(section0Title, tableSection0Title, "table view section 0 title should be equal to the one declare on initialization")
    }
    
    func testRowSelectionDisabled() {
        let selectionState = supportedFormatsViewController.tableView.allowsSelection
        
        XCTAssertFalse(selectionState, "table view cell selection should not be allowed")
    }
    
    func testSectionImageItemBackgroundColor() {
        let indexPath = IndexPath(row: 0, section: 0)

        let sectionImageItemBackgroundColor = supportedFormatsViewController.sections[indexPath.section].itemsImageBackgroundColor
        
        let cell = supportedFormatsViewController.tableView.cellForRow(at: indexPath) as! SupportedFormatsTableViewCell
        let cellImageBackgroundColor = cell.imageBackgroundView.backgroundColor
        
        XCTAssertEqual(sectionImageItemBackgroundColor, cellImageBackgroundColor, "cell iage background color should be the same as the one declared on initialization")
    }
    
}
