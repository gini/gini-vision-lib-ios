import XCTest
@testable import GiniVision

class GINIOnboardingViewControllerTests: XCTestCase {
    
    var vc = GINIOnboardingViewController(scrollViewDelegate: nil)
    
    func testConvenientInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
        XCTAssert(vc.pages == GINIConfiguration.sharedConfiguration.onboardingPages, "default pages should be set")
    }
    
    func testScrollViewAccessibility() {
        XCTAssertNotNil(vc.scrollView, "scroll view should be accessible and not nil")
    }

}
