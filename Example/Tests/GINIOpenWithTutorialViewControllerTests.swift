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
    
    var mockedItems:[OpenWithTutorialStep] {
        return [
            ("1 item title", "1 item subtitle", loadImage(withName: "tabBarIconHelp")),
            ("2 item title", "2 item subtitle", loadImage(withName: "tabBarIconHelp")),
            ("3 item title", "3 item subtitle", loadImage(withName: "tabBarIconHelp")),
            ("4 item title", "4 item subtitle", loadImage(withName: "tabBarIconHelp")),
            ("5 item title", "5 item subtitle", loadImage(withName: "tabBarIconHelp")),
            ("6 item title", "6 item subtitle", loadImage(withName: "tabBarIconHelp"))
        ]
    }
    
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
    
    func testCollectionMockedItemsCount() {
        openWithTutorialViewController.items = mockedItems
        
        let collectionSection0ItemsCount = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, numberOfItemsInSection: 0)
        
        XCTAssertEqual(6, collectionSection0ItemsCount, "the items count in section 0 should be the same as the one declared on initialization")
    }
    
    func testFirstStepProperties() {
        let indexPath = IndexPath(row: 0, section: 0)
        let item = openWithTutorialViewController.items[indexPath.row]
        
        let cell = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, cellForItemAt: indexPath) as! OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell.stepIndicator.text, String(describing: indexPath.row + 1), "step indicator for first step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepTitle.text, item.title, "step title for first step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepSubTitle.text, item.subtitle, "step subtitle for first step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepImage.image, item.image, "step image for first step should be the same as the one declared on initialiation")
    }
    
    func testSecondStepProperties() {
        let indexPath = IndexPath(row: 1, section: 0)
        let item = openWithTutorialViewController.items[indexPath.row]
        
        let cell = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, cellForItemAt: indexPath) as! OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell.stepIndicator.text, String(describing: indexPath.row + 1), "step indicator for second step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepTitle.text, item.title, "step title for second step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepSubTitle.text, item.subtitle, "step subtitle for second step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepImage.image, item.image, "step image for second step should be the same as the one declared on initialiation")
    }
    
    func testThirdStepProperties() {
        let indexPath = IndexPath(row: 2, section: 0)
        let item = openWithTutorialViewController.items[indexPath.row]
        
        let cell = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, cellForItemAt: indexPath) as! OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell.stepIndicator.text, String(describing: indexPath.row + 1), "step indicator for third step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepTitle.text, item.title, "step title for third step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepSubTitle.text, item.subtitle, "step for third step subtitle should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepImage.image, item.image, "step image for third step should be the same as the one declared on initialiation")
    }
    
    func testSixthMockedStepProperties() {
        openWithTutorialViewController.items = mockedItems
        let indexPath = IndexPath(row: 5, section: 0)
        let item = openWithTutorialViewController.items[indexPath.row]
        
        let cell = openWithTutorialViewController.collectionView(openWithTutorialViewController.collectionView!, cellForItemAt: indexPath) as! OpenWithTutorialCollectionCell
        
        XCTAssertEqual(cell.stepIndicator.text, String(describing: indexPath.row + 1), "step indicator for sixth mocked step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepTitle.text, item.title, "step title for sixth mocked step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepSubTitle.text, item.subtitle, "step subtitle for sixth mocked step should be the same as the one declared on initialiation")
        XCTAssertEqual(cell.stepImage.image, item.image, "step image for sixth mocked step should be the same as the one declared on initialiation")
    }

    func testHeaderDissapearInLandscape() {
        let collectionView = openWithTutorialViewController.collectionView!
        openWithTutorialViewController.view.frame.size = CGSize(width: 1, height: 0) // Simulate landscape
        
        let headerSize = openWithTutorialViewController.collectionView(collectionView, layout: collectionView.collectionViewLayout, referenceSizeForHeaderInSection: 0)
        
        XCTAssertEqual(headerSize.height, 0, "header size should be 0 on landscape mode")
        
    }
    
}
