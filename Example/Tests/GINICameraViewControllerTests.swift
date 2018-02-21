import XCTest
import AVFoundation
@testable import GiniVision

final class CameraViewControllerTests: XCTestCase {
    
    var vc: CameraViewController!
    
    override func setUp() {
        super.setUp()
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
    }
    
    func testInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
    }
    
    func testTooltipWhenFileImportDisabled() {
        ToolTipView.shouldShowFileImportToolTip = true
        GiniConfiguration.sharedConfiguration.fileImportSupportedTypes = .none
        _ = vc.view
        
        XCTAssertNil(vc.toolTipView, "ToolTipView should not be created when file import is disabled.")
        
    }
    
    func testCaptureButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        GiniConfiguration.sharedConfiguration.fileImportSupportedTypes = .pdf_and_images
        
        // Disable onboarding on launch
        GiniConfiguration.sharedConfiguration.onboardingShowAtLaunch = false
        GiniConfiguration.sharedConfiguration.onboardingShowAtFirstLaunch = false
        
        _ = vc.view
        
        XCTAssertFalse(vc.captureButton.isEnabled, "capture button should be disaled when tooltip is shown")
        
    }
    
    func testOpaqueViewWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        GiniConfiguration.sharedConfiguration.fileImportSupportedTypes = .pdf_and_images
        GiniConfiguration.sharedConfiguration.toolTipOpaqueBackgroundStyle = .dimmed
        
        // Disable onboarding on launch
        GiniConfiguration.sharedConfiguration.onboardingShowAtLaunch = false
        GiniConfiguration.sharedConfiguration.onboardingShowAtFirstLaunch = false
        
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        _ = vc.view
        
        XCTAssertEqual(vc.opaqueView?.backgroundColor, UIColor.black.withAlphaComponent(0.8))
    }

    func testReviewButtonBackground() {
        _ = vc.view
        
        let image = loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        XCTAssertTrue(vc.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should be hidden before capture the first picture")
        vc.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(vc.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should be hidden after capture the first picture")
        vc.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(vc.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should not be hidden after capture the second picture")
        
    }
}

