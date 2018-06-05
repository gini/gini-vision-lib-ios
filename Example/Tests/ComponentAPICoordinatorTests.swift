//
//  ComponentAPICoordinatorTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 11/13/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import Example_Swift
@testable import GiniVision

final class ComponentAPICoordinatorTests: XCTestCase {
    
    var componentAPICoordinator: ComponentAPICoordinator?
    
    func testInitialization() {
        componentAPICoordinator = ComponentAPICoordinator(pages: [],
                                                          configuration: GiniConfiguration(),
                                                          client: GiniClient(clientId: "",
                                                                             clientSecret: "",
                                                                             clientEmailDomain: ""))
        componentAPICoordinator?.start()
        
        XCTAssertNotNil(componentAPICoordinator?.rootViewController, "the root view controller should never be nil")
        XCTAssertTrue(componentAPICoordinator?.childCoordinators.count == 0,
                      "there should not be child coordinators on initialization")
    }
    
    func testInitializationWhenNoDocument() {
        componentAPICoordinator = ComponentAPICoordinator(pages: [],
                                                          configuration: GiniConfiguration(),
                                                          client: GiniClient(clientId: "",
                                                                             clientSecret: "",
                                                                             clientEmailDomain: ""))
        componentAPICoordinator?.start()
        
        XCTAssertNil(componentAPICoordinator?.analysisScreen,
                     "analysis screen should be nil when no document is imported")
        XCTAssertNil(componentAPICoordinator?.reviewScreen,
                     "review screen should be nil when no document is imported")
        XCTAssertNotNil(componentAPICoordinator?.cameraScreen,
                        "camera screen should not be nil when no document is imported")

    }
    
    func testInitializationWhenImageImported() {
        let image = GiniVisionTestsHelper.loadImage(withName: "tabBarIconHelp")
        let builder = GiniVisionDocumentBuilder(data: UIImagePNGRepresentation(image!), documentSource: .external)
        let document = builder.build()!
        
        componentAPICoordinator = ComponentAPICoordinator(pages: [GiniVisionPage(document: document)],
                                                          configuration: GiniConfiguration(),
                                                          client: GiniClient(clientId: "",
                                                                             clientSecret: "",
                                                                             clientEmailDomain: ""))
        componentAPICoordinator?.start()
        
        XCTAssertNil(componentAPICoordinator?.analysisScreen,
                     "analysis screen should be nil when no document is imported")
        XCTAssertNotNil(componentAPICoordinator?.reviewScreen,
                        "review screen should not be nil when a image is imported")
        XCTAssertNil(componentAPICoordinator?.cameraScreen,
                     "camera screen should be nil when a image is imported")
        
        XCTAssertEqual(componentAPICoordinator?.reviewScreen?.navigationItem.leftBarButtonItem?.title,
                       "Schließen")
        
    }
    
    func testInitializationWhenPDFImported() {
        let pdfDocument = GiniVisionTestsHelper.loadPDFDocument(withName: "testPDF")
        
        componentAPICoordinator = ComponentAPICoordinator(pages: [GiniVisionPage(document: pdfDocument)],
                                                          configuration: GiniConfiguration(),
                                                          client: GiniClient(clientId: "",
                                                                             clientSecret: "",
                                                                             clientEmailDomain: ""))
        componentAPICoordinator?.start()
        
        XCTAssertNotNil(componentAPICoordinator?.analysisScreen,
                        "analysis screen should not be nil when a pdf is imported")
        XCTAssertNil(componentAPICoordinator?.reviewScreen,
                     "review screen should be nil when a pdf is imported")
        XCTAssertNil(componentAPICoordinator?.cameraScreen,
                     "camera screen should be nil when a pdfpdf is imported")
        
        XCTAssertEqual(componentAPICoordinator?.analysisScreen?.navigationItem.leftBarButtonItem?.title,
                       "Schließen")
    }
    
}
