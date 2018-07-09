//
//  CameraViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
import AVFoundation
@testable import GiniVision

final class CameraViewControllerTests: XCTestCase {
    
    var cameraViewController: CameraViewController!
    var giniConfiguration: GiniConfiguration!
    var screenAPICoordinator: GiniScreenAPICoordinator!
    let visionDelegateMock = GiniVisionDelegateMock()
    lazy var imageData: Data = {
        let image = GiniVisionTestsHelper.loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)!
        return imageData
    }()

    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration.shared
        giniConfiguration.multipageEnabled = true
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        screenAPICoordinator = GiniScreenAPICoordinator(withDelegate: visionDelegateMock,
                                                        giniConfiguration: self.giniConfiguration)
        cameraViewController.delegate = screenAPICoordinator
    }
    
    func testInitialization() {
        XCTAssertNotNil(cameraViewController, "view controller should not be nil")
    }
    
    func testTooltipWhenFileImportDisabled() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .none
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        _ = cameraViewController.view
        
        XCTAssertNil(cameraViewController.toolTipView,
                     "ToolTipView should not be created when file import is disabled.")
    }
    
    func testCaptureButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        
        // Disable onboarding on launch
        giniConfiguration.onboardingShowAtLaunch = false
        giniConfiguration.onboardingShowAtFirstLaunch = false
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        
        _ = cameraViewController.view
        
        XCTAssertFalse(cameraViewController.captureButton.isEnabled,
                       "capture button should be disaled when tooltip is shown")
    }
    
    func testOpaqueViewWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        GiniConfiguration.shared.fileImportSupportedTypes = .pdf_and_images
        GiniConfiguration.shared.toolTipOpaqueBackgroundStyle = .dimmed
        
        // Disable onboarding on launch
        GiniConfiguration.shared.onboardingShowAtLaunch = false
        GiniConfiguration.shared.onboardingShowAtFirstLaunch = false
        
        cameraViewController = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        _ = cameraViewController.view
        
        XCTAssertEqual(cameraViewController.opaqueView?.backgroundColor, UIColor.black.withAlphaComponent(0.8))
    }

}

