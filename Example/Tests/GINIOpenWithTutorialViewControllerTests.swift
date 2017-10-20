//
//  GINIOpenWithTutorialViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/20/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

class GINIOpenWithTutorialViewControllerTests: XCTestCase {
    
    let openWithTutorialViewController = OpenWithTutorialViewController()
    
    override func setUp() {
        super.setUp()
        _ = openWithTutorialViewController.view
    }
    
    func testSectionCount() {
        let sectionsCount = openWithTutorialViewController.numberOfSections(in: openWithTutorialViewController.collectionView!)
        
        XCTAssertEqual(sectionsCount, 1, "sections count should always be 1")
    }
    
    func testCollectionItemsCount() {
        let itemsCount = openWithTutorialViewController.items.count
        
        let collectionSection0ItemsCount = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, numberOfItemsInSection: 0)
        
        XCTAssertEqual(itemsCount, collectionSection0ItemsCount, "the items count in section 0 should be the same as the one declared on initialization")
    }
    
    func testCellFields() {
        let indexPath = IndexPath(row: 0, section: 0)
        let item = openWithTutorialViewController.items[indexPath.row]
        
        let cell = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, cellForItemAt: indexPath) as! OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell.stepIndicator.text, String(describing: indexPath.row + 1), "step indicator should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepTitle.text, item.title, "step title should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepSubTitle.text, item.subtitle, "step subtitle should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepImage.image, item.image, "step image should be the same as the one declared on initialiation")

    }
    
}
