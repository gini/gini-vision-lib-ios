//
//  GINIComponentAPICoordinator.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 11/13/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision_Example
@testable import GiniVision

class GINIComponentAPICoordinator: XCTestCase {
    
    let documentService = DocumentService()
    var componentAPICoordinator: ComponentAPICoordinator?
    
    func testInitialization() {
        componentAPICoordinator = ComponentAPICoordinator(document: nil, configuration: GiniConfiguration(), documentService: self.documentService)

        XCTAssertNotNil(componentAPICoordinator?.rootViewController, "the root view controller should never be nil")
        XCTAssertTrue(componentAPICoordinator?.childCoordinators.count == 0, "there should not be child coordinators on initialization")
    }
    
    func testFirstScreenWhenNoDocument() {
        componentAPICoordinator = ComponentAPICoordinator(document: nil, configuration: GiniConfiguration(), documentService: self.documentService)
        
        componentAPICoordinator?.start()
        
        XCTAssertNil(componentAPICoordinator?.analysisScreen, "analysis screen should be nil when no document is imported")
        XCTAssertNil(componentAPICoordinator?.reviewScreen, "review screen should be nil when no document is imported")
        XCTAssertNotNil(componentAPICoordinator?.cameraScreen, "camera screen should not be nil when no document is imported")

    }
    
}
