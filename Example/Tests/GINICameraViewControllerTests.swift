import XCTest
@testable import GiniVision

class CameraViewControllerTests: XCTestCase {
    
    var vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
    
    func testInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
    }
    
    func testCameraOverlayAccessibility() {
        XCTAssertNotNil(vc.cameraOverlay, "camera overlay should be accessible and not nil")
    }
    
}

