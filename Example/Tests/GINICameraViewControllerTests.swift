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
    
    func testReviewImagesButtonTouchInteraction() {
        _ = vc.view
        
        let image = loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        XCTAssertFalse(vc.multipageReviewButton.isUserInteractionEnabled,
                       "multipageReviewButton should be disabled on start")
        
        vc.cameraDidCapture(imageData: imageData, error: nil)
        
        let predicate = NSPredicate(format: "isUserInteractionEnabled == YES")
        
        _ = self.expectation(for: predicate,
                             evaluatedWith: vc.multipageReviewButton,
                             handler: .none)
        waitForExpectations(timeout: 1.5, handler: { result in
            XCTAssertNil(result, "multipageReviewButton should be enabled after capturing a picture")
            XCTAssertTrue(self.vc.multipageReviewBackgroundView.isHidden,
                          "multipageReviewBackgroundView should be hidden before capture the first picture")
            self.vc.cameraDidCapture(imageData: imageData, error: nil)
            
            let predicate = NSPredicate(format: "isHidden == NO")
            
            _ = self.expectation(for: predicate,
                                 evaluatedWith: self.vc.multipageReviewBackgroundView,
                                 handler: .none)
            self.waitForExpectations(timeout: 1.5, handler: { result in
                XCTAssertFalse(self.vc.multipageReviewBackgroundView.isHidden,
                              "multipageReviewBackgroundView should not be hidden after capture the second picture")
            })
        })
        
    }
}

