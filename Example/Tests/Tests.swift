@testable import GiniVision
import Foundation
import XCTest

class GINIOnboardingViewControllerTest: XCTestCase {
    
    func testSuccessfulScrollToNextPage() {
        let pages = [ UIView(), UIView() ]
        let onboardingVC = GINIOnboardingViewController(pages: pages, scrollViewDelegate: nil)

        XCTAssertTrue(onboardingVC.scrollToNextPage(false), "should be able to scroll to next page")
    }
    
    func testFailingScrollToNextPage() {
        let pages = [ UIView() ]
        let onboardingVC = GINIOnboardingViewController(pages: pages, scrollViewDelegate: nil)
        
        XCTAssertFalse(onboardingVC.scrollToNextPage(false), "should not be able to scroll to next page")
    }
    
}