import XCTest
import AVFoundation
@testable import GiniVision

final class CameraViewControllerTests: XCTestCase {
    
    var cameraViewController: CameraViewController!
    var giniConfiguration: GiniConfiguration!
    var screenAPICoordinator: GiniScreenAPICoordinator!
    lazy var imageData: Data = {
        let image = self.loadImage(withName: "invoice.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 0.9)!
        return imageData
    }()

    
    override func setUp() {
        super.setUp()
        giniConfiguration = GiniConfiguration.sharedConfiguration
        giniConfiguration.multipageEnabled = true
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        screenAPICoordinator = GiniScreenAPICoordinator(withDelegate: nil,
                                                        giniConfiguration: self.giniConfiguration)
        cameraViewController.delegate = screenAPICoordinator
    }
    
    func testInitialization() {
        XCTAssertNotNil(cameraViewController, "view controller should not be nil")
    }
    
    func testTooltipWhenFileImportDisabled() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .none
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        _ = cameraViewController.view
        
        XCTAssertNil(cameraViewController.toolTipView, "ToolTipView should not be created when file import is disabled.")
        
    }
    
    func testCaptureButtonDisabledWhenToolTipIsShown() {
        ToolTipView.shouldShowFileImportToolTip = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        
        // Disable onboarding on launch
        giniConfiguration.onboardingShowAtLaunch = false
        giniConfiguration.onboardingShowAtFirstLaunch = false
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        
        _ = cameraViewController.view
        
        XCTAssertFalse(cameraViewController.captureButton.isEnabled, "capture button should be disaled when tooltip is shown")
        
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
    
    func testReviewButtonBackgroundBeforeCapturing() {
        _ = cameraViewController.view

        XCTAssertTrue(cameraViewController.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should be hidden before capture the first picture")
        
    }
    
    func testReviewButtonBackgroundAfter1ImageWasCaptured() {
        _ = cameraViewController.view

        cameraViewController.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(cameraViewController.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should be hidden after capture the first picture")
        
    }
    
    func testReviewButtonBackgroundAfter2ImagesWereCaptured() {
        _ = cameraViewController.view

        cameraViewController.cameraDidCapture(imageData: imageData, error: nil)
        cameraViewController.cameraDidCapture(imageData: imageData, error: nil)
        XCTAssertTrue(cameraViewController.multipageReviewBackgroundView.isHidden,
                      "multipageReviewBackgroundView should not be hidden after capture the second picture")
        
    }
    
    func testPickerCompletionBlockWhenNoErrorsOccurred() {
        let documents = [GiniImageDocument(data: imageData, imageSource: .external)]
        let expect = expectation(description: "Document validation finishes")

        cameraViewController.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            XCTAssertNil(error, "Completion block should not return an error when pciking one image")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPickerCompletionBlockWhenNoErrorsOccurredWithDeprecatedInit() {
        let documents = [loadImageDocument(withName: "invoice")]
        let expect = expectation(description: "Document validation finishes")
        cameraViewController = CameraViewController(success: {_ in}, failure: {_ in})
        cameraViewController.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
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
        
        cameraViewController.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            XCTAssertNil(error, "Completion block should not return an error from outside when it is a PDF")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPickerCompletionBlockWhenFailedImageAndMultipageDisabled() {
        let failedImage = loadImageDocument(withName: "invoice")
        failedImage.error = DocumentValidationError.imageFormatNotValid
        let documents = [failedImage]
        
        giniConfiguration.multipageEnabled = false
        cameraViewController = CameraViewController(giniConfiguration: giniConfiguration)
        cameraViewController.delegate = screenAPICoordinator
        
        let expect = expectation(description: "Document validation finishes")

        cameraViewController.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
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
        cameraViewController.documentPicker(DocumentPickerCoordinator(), didPick: documents, from: .gallery) { error, _ in
            expect.fulfill()
            let error = error as? FilePickerError
            XCTAssertTrue(error == FilePickerError.maxFilesPickedCountExceeded,
                          "Completion block should return the FilePickerError.maxFilesPickedCountExceeded error from outside of the camera screen")
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    
}

