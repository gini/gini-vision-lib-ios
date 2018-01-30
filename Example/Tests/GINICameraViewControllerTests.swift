import XCTest
import AVFoundation
@testable import GiniVision

class CameraViewControllerTests: XCTestCase {
    
    var vc: CameraViewController!
    
    func testInitialization() {
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        XCTAssertNotNil(vc, "view controller should not be nil")
    }
    
    func testTooltipWhenFileImportDisabled() {
        ToolTipView.shouldShowFileImportToolTip = true
        GiniConfiguration.sharedConfiguration.fileImportSupportedTypes = .none
        
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        _ = vc.view
        
        XCTAssertNil(vc.toolTipView, "ToolTipView should not be created when file import is disabled.")
        
    }
    
    func testCaptureButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        GiniConfiguration.sharedConfiguration.fileImportSupportedTypes = .pdf_and_images
        
        // Disable onboarding on launch
        GiniConfiguration.sharedConfiguration.onboardingShowAtLaunch = false
        GiniConfiguration.sharedConfiguration.onboardingShowAtFirstLaunch = false
        
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        _ = vc.view
        
        XCTAssertFalse(vc.captureButton.isEnabled, "capture button should be disaled when tooltip is shown")
        
    }
    
    func testReviewButtonBackground() {
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        _ = vc.view
        
        let image = loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        XCTAssertTrue(vc.reviewBackgroundView.isHidden,
                      "ReviewBackgroundView should be hidden before capture the first picture")
        vc.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(vc.reviewBackgroundView.isHidden,
                      "ReviewBackgroundView should be hidden after capture the first picture")
        vc.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(vc.reviewBackgroundView.isHidden,
                      "ReviewBackgroundView should not be hidden after capture the second picture")

    }
    
    func testReviewImagesButtonTouchInteraction() {
        vc = CameraViewController(successBlock: { _ in }, failureBlock: { _ in })
        _ = vc.view
        
        let image = loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        XCTAssertFalse(vc.reviewImagesButton.isUserInteractionEnabled,
                       "reviewImagesButton should be disabled on start")
        
        XCTAssertTrue(vc.reviewBackgroundView.isHidden,
                      "ReviewBackgroundView should be hidden before capture the first picture")
        vc.cameraDidCapture(imageData: imageData, error: nil)
        
        let predicate = NSPredicate(format: "isUserInteractionEnabled == YES")

        _ = self.expectation(for: predicate,
                             evaluatedWith: vc.reviewImagesButton,
                             handler: .none)
        waitForExpectations(timeout: 1.5, handler: { result in
            XCTAssertNil(result, "reviewImagesButton should be enabled after capturing a picture")
        })

    }
}

