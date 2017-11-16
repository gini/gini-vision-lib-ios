//
//  GINISettingsViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 11/16/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision_Example
@testable import GiniVision

class GINISettingsViewControllerTests: XCTestCase {
    let settingsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
    
    override func setUp() {
        super.setUp()
        settingsViewController.giniConfiguration = GiniConfiguration()
        _ = settingsViewController.view

    }
    
    func testSegmentedControlNone() {
        settingsViewController.fileImportControl.selectedSegmentIndex = 0
        settingsViewController.fileImportControl.sendActions(for: .valueChanged)
        XCTAssertEqual(settingsViewController.giniConfiguration.fileImportSupportedTypes, .none, "none types should be supported in the gini configuration")
    }
    
    func testSegmentedControlPDF() {
        settingsViewController.fileImportControl.selectedSegmentIndex = 1
        settingsViewController.fileImportControl.sendActions(for: .valueChanged)
        XCTAssertEqual(settingsViewController.giniConfiguration.fileImportSupportedTypes, .pdf, "pdf type should be supported in the gini configuration")
    }
    
    func testSegmentedControlPDFAndImages() {
        settingsViewController.fileImportControl.selectedSegmentIndex = 2
        settingsViewController.fileImportControl.sendActions(for: .valueChanged)
        XCTAssertEqual(settingsViewController.giniConfiguration.fileImportSupportedTypes, .pdf_and_images, "pdf and image types should be supported in the gini configuration")
    }
    
    func testSwitchOn() {
        settingsViewController.openWithSwitch.isOn = true
        settingsViewController.openWithSwitch.sendActions(for: .valueChanged)
        
        XCTAssertTrue(settingsViewController.giniConfiguration.openWithEnabled, "open with feature should be enabled in the gini configuration")
    }
    
    func testSwitchOff() {
        settingsViewController.openWithSwitch.isOn = false
        settingsViewController.openWithSwitch.sendActions(for: .valueChanged)

        XCTAssertFalse(settingsViewController.giniConfiguration.openWithEnabled, "open with feature should not be enabled in the gini configuration")
    }
}
