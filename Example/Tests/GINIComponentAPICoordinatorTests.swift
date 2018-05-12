//
//  GINIComponentAPICoordinatorTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 11/13/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision_Example
@testable import GiniVision

class GINIComponentAPICoordinatorTests: XCTestCase {
    
    var componentAPICoordinator: ComponentAPICoordinator?
    
    func testInitialization() {
        componentAPICoordinator = ComponentAPICoordinator(documentRequests: [],
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
        componentAPICoordinator = ComponentAPICoordinator(documentRequests: [],
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
        let image = loadImage(withName: "tabBarIconHelp")
        let builder = GiniVisionDocumentBuilder(data: UIImagePNGRepresentation(image!), documentSource: .external)
        let document = builder.build()!
        
        componentAPICoordinator = ComponentAPICoordinator(documentRequests: [DocumentRequest(value: document)],
                                                          configuration: GiniConfiguration(),
                                                          client: GiniClient(clientId: "",
                                                                             clientSecret: "",
                                                                             clientEmailDomain: ""))
        componentAPICoordinator?.start()
        
        XCTAssertNil(componentAPICoordinator?.analysisScreen,
                     "analysis screen should be nil when a image is imported")
        XCTAssertNotNil(componentAPICoordinator?.reviewScreen,
                        "review screen should not be nil when a image is imported")
        XCTAssertNil(componentAPICoordinator?.cameraScreen,
                     "camera screen should be nil when a image is imported")
        
        XCTAssertEqual(componentAPICoordinator?.reviewScreen?.navigationItem.leftBarButtonItem?.title,
                       "Schließen")
        
    }
    
    func testInitializationWhenPDFImported() {
        let pdfDocument = loadPDFDocument(withName: "testPDF")
        
        componentAPICoordinator = ComponentAPICoordinator(documentRequests: [DocumentRequest(value: pdfDocument)],
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
