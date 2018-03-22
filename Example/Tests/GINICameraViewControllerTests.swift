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
    var giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration
    lazy var screenAPICoordinator = GiniScreenAPICoordinator(withDelegate: nil,
                                                             giniConfiguration: self.giniConfiguration)
    
    override func setUp() {
        super.setUp()
        giniConfiguration.multipageEnabled = true
        vc = CameraViewController(giniConfiguration: giniConfiguration)
        vc.delegate = screenAPICoordinator
    }
    
    func testInitialization() {
        XCTAssertNotNil(vc, "view controller should not be nil")
    }
    
    func testTooltipWhenFileImportDisabled() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .none
        vc = CameraViewController(giniConfiguration: giniConfiguration)
        _ = vc.view
        
        XCTAssertNil(vc.toolTipView, "ToolTipView should not be created when file import is disabled.")
        
    }
    
    func testCaptureButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        
        // Disable onboarding on launch
        giniConfiguration.onboardingShowAtLaunch = false
        giniConfiguration.onboardingShowAtFirstLaunch = false
        vc = CameraViewController(giniConfiguration: giniConfiguration)
        
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
    
    func testPickerCompletionBlockWhenNoErrors() {
        let documents = [GiniImageDocument(data: imageData, imageSource: .external)]
        let expect = expectation(description: "Document validation finishes")

        vc.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            XCTAssertNil(error, "Completion block should not return an error when pciking one image")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPickerCompletionBlockWhenNoErrorsWithDeprecatedInit() {
        let documents = [loadImageDocument(withName: "invoice")]
        let expect = expectation(description: "Document validation finishes")
        vc = CameraViewController(success: {_ in}, failure: {_ in})
        vc.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            XCTAssertNil(error, "Completion block should not return an error when using the deprecated initializer")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPickerCompletionBlockWhenFailedPDF() {
        let failedPDF = loadPDFDocument(withName: "testPDF")
        failedPDF.error = DocumentValidationError.pdfPageLengthExceeded
        let documents = [failedPDF]
        let expect = expectation(description: "Document validation finishes")
        
        vc.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            XCTAssertNil(error, "Completion block should not return an error form outside when it is a PDF")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPickerCompletionBlockWhenFailedImageAndMultipageDisabled() {
        let failedImage = loadImageDocument(withName: "invoice")
        failedImage.error = DocumentValidationError.imageFormatNotValid
        let documents = [failedImage]
        
        giniConfiguration.multipageEnabled = false
        vc = CameraViewController(giniConfiguration: giniConfiguration)
        vc.delegate = screenAPICoordinator
        
        let expect = expectation(description: "Document validation finishes")

        vc.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            XCTAssertNil(error, "When multipage is disabled there should not be an error coming from outside of the camera screen")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPickerCompletionBlockWhenTooManyPages() {
        var documents: [GiniVisionDocument] = []
        for _ in 0...GiniPDFDocument.maxPagesCount {
            documents.append(loadImageDocument(withName: "invoice"))
        }

        let expect = expectation(description: "Document validation finishes")
        vc.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            let error = error as? FilePickerError
            XCTAssertTrue(error == FilePickerError.filesPickedCountExceeded,
                          "Completion block should return the filesPickedCounteExceedede error from outside of the caera screen")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    
}

