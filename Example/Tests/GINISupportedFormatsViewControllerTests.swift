//
//  GINIsupportedFormatsViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GINISupportedFormatsViewControllerTests: XCTestCase {
    
    let supportedFormatsViewController = SupportedFormatsViewController(style: .plain)
    
    var mockedSections:[(String, [String], UIImage?, UIColor)] {
        return [
            ("Section 1",["Item 1 Section 1", "Item 2 Section 1", "Item 3 Section 1"], loadImage(withName: "tabBarIconHelp"), UIColor.green),
            ("Section 2",["Item 1 Section 1", "Item 2 Section 2"], loadImage(withName: "tabBarIconHelp"), UIColor.red),
            ("Section 3",["Item 1 Section 3"], loadImage(withName: "tabBarIconHelp"), UIColor.yellow)
        ]
    }
    
    override func setUp() {
        super.setUp()

        _ = supportedFormatsViewController.view
    }
    
    func testSectionsCount() {
        supportedFormatsViewController.sections = mockedSections
        
        let tableSectionsCount = supportedFormatsViewController.numberOfSections(in: supportedFormatsViewController.tableView)
        
        XCTAssertEqual(3, tableSectionsCount, "sections count and table sections count should be always equal")
    }
    
    func testSectionsMockedCount() {
        let sectionsCount = supportedFormatsViewController.sections.count
        
        let tableSectionsCount = supportedFormatsViewController.numberOfSections(in: supportedFormatsViewController.tableView)
        
        XCTAssertEqual(sectionsCount, tableSectionsCount, "sections count and table sections count should be always equal")
    }
    
    func testSectionItemsCount() {
        supportedFormatsViewController.sections = mockedSections

        let section3ItemsCount = 1
        let tableSection3ItemsCount = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, numberOfRowsInSection: 2)
        
        XCTAssertEqual(section3ItemsCount, tableSection3ItemsCount, "items count inside section 3 and table section 3 items count should be always equal")
    }
    
    func testTableCellMockedText() {
        supportedFormatsViewController.sections = mockedSections

        let indexPath = IndexPath(row: 1, section: 1)
        let textForItem2tSection2 = "Item 2 Section 2"
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem2tSection2, "text for item 2 at section 2 should be equal to the one declared on initialization")
    }
    
    func testTableCellText() {
        let indexPath = IndexPath(row: 0, section: 0)
        let textForItem0tSection0 = supportedFormatsViewController.sections[0].items[0]
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0tSection0, "text for item 0 at section 0 should be equal to the one declared on initialization")
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
        supportedFormatsViewController.sections = mockedSections

        let section1Title = "Section 1"
        let tableSection1Title = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, titleForHeaderInSection: 0)
        
        XCTAssertEqual(section1Title, tableSection1Title, "table view section 1 title should be equal to the one declare on initialization")
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
        
        XCTAssertEqual(sectionImageItemBackgroundColor, cellImageBackgroundColor, "cell image background color should be the same as the one declared on initialization")
    }
    
    func testTableViewCellType() {
        let indexPath = IndexPath(row: 0, section: 0)

        let cell = supportedFormatsViewController.tableView.cellForRow(at: indexPath)
        
        XCTAssertNotNil(cell as? SupportedFormatsTableViewCell, "cell in this table view should always be of type SupportedFormatsTableViewCell")
    }
    
}
