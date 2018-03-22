//
//  GiniScreenAPICoordinatorTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 3/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GiniScreenAPICoordinatorTests: XCTestCase {
    
    var coordinator: GiniScreenAPICoordinator!
    let giniConfiguration = GiniConfiguration()
    let delegate = GiniVisionDelegateMock()
    
    override func setUp() {
        super.setUp()
        giniConfiguration.openWithEnabled = true
        giniConfiguration.multipageEnabled = true
        coordinator = GiniScreenAPICoordinator(withDelegate: delegate, giniConfiguration: giniConfiguration)
    }
    
    func testNavControllerCountAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? CameraViewController,
                        "first view controller is not a CameraViewController")
    }
    
    func testNavControllerCountAfterStartWithImages() {
        let capturedImages = [loadImageDocument(withName: "invoice"), loadImageDocument(withName: "invoice2")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 2,
                       "there should be 2 view controllers in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithImages() {
        let capturedImages = [loadImageDocument(withName: "invoice"), loadImageDocument(withName: "invoice2")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? CameraViewController,
                        "first view controller is not a CameraViewController")
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? MultipageReviewController,
                        "last view controller is not a MultipageReviewController")
    }
    
    func testNavControllerCountAfterStartWithAPDF() {
        let capturedPDFs = [loadPDFDocument(withName: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithPDF() {
        let capturedPDFs = [loadPDFDocument(withName: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? AnalysisViewController,
                        "first view controller is not a AnalysisViewController")
    }
    
    func testNavControllerTypesAfterStartWithImageAndMultipageDisabled() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [loadImageDocument(withName: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.childViewControllers.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
    }
    
    func testCameraDidCaptureImagesWithEmptyArray(){
        let capturedImages = [loadImageDocument(withName: "invoice"), loadImageDocument(withName: "invoice2")]
        coordinator.camera(CameraViewController(giniConfiguration: giniConfiguration), didCaptureDocuments: capturedImages, completion: nil)
        
        XCTAssertEqual(coordinator.visionDocuments.count, 2,
                       "vision documents count should match the number of images captured")
    }
    
    func testCameraDidCaptureImagesWithNotEmptyArray(){
        let capturedImages = [loadImageDocument(withName: "invoice"), loadImageDocument(withName: "invoice2")]
        coordinator.camera(CameraViewController(giniConfiguration: giniConfiguration), didCaptureDocuments: capturedImages, completion: nil)
        coordinator.camera(CameraViewController(giniConfiguration: giniConfiguration), didCaptureDocuments: capturedImages, completion: nil)

        XCTAssertEqual(coordinator.visionDocuments.count, 4,
                       "vision documents count should match the number of images captured")
    }
    
    func testCameraDidCapturePDFWithEmptyArray(){
        let capturedPDFs = [loadPDFDocument(withName: "testPDF")]
        coordinator.camera(CameraViewController(giniConfiguration: giniConfiguration), didCaptureDocuments: capturedPDFs, completion: nil)
        
        XCTAssertEqual(coordinator.visionDocuments.count, 1,
                       "vision documents count should match the number of PDF captured")
    }
    
    func testCameraDidCapturePDFWithExistingImages(){
        let capturedImages = [loadImageDocument(withName: "invoice"), loadImageDocument(withName: "invoice2")]
        let capturedPDFs = [loadPDFDocument(withName: "testPDF")]
        coordinator.camera(CameraViewController(giniConfiguration: giniConfiguration), didCaptureDocuments: capturedImages, completion: nil)
        coordinator.camera(CameraViewController(giniConfiguration: giniConfiguration), didCaptureDocuments: capturedPDFs, completion: nil)
        
        XCTAssertEqual(coordinator.visionDocuments.count, 2,
                       "vision documents count should be 2 since it can not be a mixed array")
    }
    
}
