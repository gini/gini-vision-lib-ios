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
    let delegateMock = GiniVisionDelegateMock()
    
    override func setUp() {
        super.setUp()
        giniConfiguration.openWithEnabled = true
        giniConfiguration.multipageEnabled = true
        coordinator = GiniScreenAPICoordinator(withDelegate: delegateMock, giniConfiguration: giniConfiguration)
    }
    
    func testNavControllerCountAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithoutDocuments() {
        let rootViewController = coordinator.start(withDocuments: nil)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? CameraViewController,
                        "first view controller is not a CameraViewController")
    }
    
    func testNavControllerCountAfterStartWithImages() {
        let capturedImages = [GiniVisionTestsHelper.loadImageDocument(named: "invoice"),
                              GiniVisionTestsHelper.loadImageDocument(named: "invoice2")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 2,
                       "there should be 2 view controllers in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithImages() {
        let capturedImages = [GiniVisionTestsHelper.loadImageDocument(named: "invoice"),
                              GiniVisionTestsHelper.loadImageDocument(named: "invoice2")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? CameraViewController,
                        "first view controller is not a CameraViewController")
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? MultipageReviewViewController,
                        "last view controller is not a MultipageReviewController")
    }
    
    func testNavControllerCountAfterStartWithAPDF() {
        let capturedPDFs = [GiniVisionTestsHelper.loadPDFDocument(named: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        XCTAssertEqual(screenNavigator?.viewControllers.count, 1,
                       "there should be only one view controller in the nav stack")
    }
    
    func testNavControllerTypesAfterStartWithPDF() {
        let capturedPDFs = [GiniVisionTestsHelper.loadPDFDocument(named: "testPDF")]

        let rootViewController = coordinator.start(withDocuments: capturedPDFs)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.first as? AnalysisViewController,
                        "first view controller is not a AnalysisViewController")
    }
    
    func testNavControllerTypesAfterStartWithImageAndMultipageDisabled() {
        giniConfiguration.multipageEnabled = false
        let capturedImages = [GiniVisionTestsHelper.loadImageDocument(named: "invoice")]

        let rootViewController = coordinator.start(withDocuments: capturedImages)
        _ = rootViewController.view
        let screenNavigator = rootViewController.children.first as? UINavigationController
        
        XCTAssertNotNil(screenNavigator?.viewControllers.last as? ReviewViewController,
                        "first view controller is not a ReviewViewController")
    }
    
    func testDocumentCollectionAfterRotateImageInMultipage() {
        let capturedImageDocument = GiniVisionTestsHelper.loadImagePage(named: "invoice")
        coordinator.addToDocuments(new: [capturedImageDocument])
        
        (coordinator.multiPageReviewViewController
            .pages[0]
            .document as? GiniImageDocument)?
            .rotatePreviewImage90Degrees()
        coordinator.multipageReview(coordinator.multiPageReviewViewController,
                                    didRotate: coordinator.multiPageReviewViewController.pages[0])

        let imageDocument = coordinator.pages[0].document as? GiniImageDocument
        XCTAssertEqual(imageDocument?.rotationDelta, 90,
                       "the image document rotation delta should have been updated after rotation")
    }
    
    func testDocumentCollectionAfterRemoveImageInMultipage() {
        let capturedImageDocument = GiniVisionTestsHelper.loadImagePage(named: "invoice")
        coordinator.addToDocuments(new: [capturedImageDocument])
        
        coordinator.multipageReview(coordinator.multiPageReviewViewController,
                                    didDelete: coordinator.multiPageReviewViewController.pages[0])
        XCTAssertTrue(coordinator.pages.isEmpty,
                      "vision documents collection should be empty after delete " +
            "the image in the multipage review view controller")
    }
    
    func testMultipageImageDocumentWhenSortingDocuments() {
        let capturedImageDocument = [GiniVisionTestsHelper.loadImagePage(named: "invoice"),
                                     GiniVisionTestsHelper.loadImagePage(named: "invoice")]
        let firstItemId = capturedImageDocument.first?.document.id
        coordinator.addToDocuments(new: capturedImageDocument)
        
        var reorderedItems = capturedImageDocument
        reorderedItems.swapAt(0, 1)
        
        coordinator.multipageReview(coordinator.multiPageReviewViewController, didReorder: reorderedItems)
        
        XCTAssertTrue(coordinator.pages.last?.document.id == firstItemId, "last items should be the one moved")
        
    }
}
