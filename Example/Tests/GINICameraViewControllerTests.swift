import XCTest
@testable import GiniVision

class CameraViewControllerTests: XCTestCase {
    
    var vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
    
    func testInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
    }
    
}

