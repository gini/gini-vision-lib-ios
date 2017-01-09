import XCTest
@testable import GiniVision

class GINICameraViewControllerTests: XCTestCase {
    
    var vc = GINICameraViewController(success: { _ in }, failure: { _ in })
    
    func testInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
    }
    
    func testCameraOverlayAccessibility() {
        XCTAssertNotNil(vc.cameraOverlay, "camera overlay should be accessible and not nil")
    }
    
}

