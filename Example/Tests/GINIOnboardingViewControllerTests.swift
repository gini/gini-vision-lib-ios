import XCTest
@testable import GiniVision

class OnboardingViewControllerTests: XCTestCase {
    
    var vc = OnboardingViewController(scrollViewDelegate: nil)
    
    func testConvenientInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
        XCTAssert(vc.pages == GiniConfiguration.sharedConfiguration.onboardingPages, "default pages should be set")
    }
    
    func testScrollViewAccessibility() {
        XCTAssertNotNil(vc.scrollView, "scroll view should be accessible and not nil")
    }
}
