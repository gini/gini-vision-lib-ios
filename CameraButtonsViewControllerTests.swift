//
//  CameraButtonsViewControllerTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 2/19/19.
//

import XCTest
import AVFoundation
@testable import GiniVision

final class CameraButtonsViewControllerTests: XCTestCase {
    
    var cameraButtonsViewController: CameraButtonsViewController!
    var giniConfiguration: GiniConfiguration!
    var screenAPICoordinator: GiniScreenAPICoordinator!
    let visionDelegateMock = GiniVisionDelegateMock()
    lazy var imageData: Data = {
        let image = GiniVisionTestsHelper.loadImage(named: "invoice")
        let imageData = image.jpegData(compressionQuality: 0.9)!
        return imageData
    }()
    
    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration.shared
        giniConfiguration.multipageEnabled = true
        cameraButtonsViewController = CameraButtonsViewController(giniConfiguration: giniConfiguration,
                                                                  isFlashSupported: true)
    }
    
}
