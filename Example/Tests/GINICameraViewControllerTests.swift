import XCTest
import AVFoundation
@testable import GiniVision

final class CameraViewControllerTests: XCTestCase {
    
    var vc: CameraViewController!
    lazy var imageData: Data = {
        let image = self.loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)!
        return imageData
    }()
    
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
    
    func testReviewButtonBackgroundBeforeCapturing() {
        _ = vc.view

        XCTAssertTrue(vc.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should be hidden before capture the first picture")
        
    }
    
    func testReviewButtonBackgroundAfter1ImageWasCaptured() {
        _ = vc.view

        vc.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(vc.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should be hidden after capture the first picture")
        
    }
    
    func testReviewButtonBackgroundAfter2ImagesWereCaptured() {
        _ = vc.view

        vc.cameraDidCapture(imageData: imageData, error: nil)
        vc.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(vc.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should not be hidden after capture the second picture")
        
    }
}

