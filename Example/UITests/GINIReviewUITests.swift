import XCTest

class GINIReviewUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments = [ "--UITest" ]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app.terminate()
    }
    
    func testReviewIsPresent() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        
        let rotationButton = app.buttons["Dokument drehen"]
        XCTAssert(rotationButton.exists, "rotation button should exist indicating that the library was started correctly and is presenting the review screen after taking an image")
    }
    
    func testRotation() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        
        let documentImage = app.images["Dokument"]
        let frame = documentImage.frame
        let aspectRatio = (CGRectGetWidth(frame) / CGRectGetHeight(frame)).roundToPlaces(1)
        app.buttons["Dokument drehen"].tap()
        let rotatedFrame = documentImage.frame
        let rotatedAspectRatio = (CGRectGetWidth(rotatedFrame) / CGRectGetHeight(rotatedFrame)).roundToPlaces(1)
        
        let rotated = aspectRatio == pow(rotatedAspectRatio, -1).roundToPlaces(1)
        XCTAssert(rotated, "document should be rotated which means length and width switched values")
    }
    
    func testDoubleTapToZoom() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        
        let documentImage = app.images["Dokument"]
        let frame = documentImage.frame
        documentImage.doubleTap()
        let zoomedFrame = documentImage.frame
        
        let zoomed = frame != zoomedFrame
        XCTAssert(zoomed, "document should be zoomed after double tapping")
    }
    
}

extension CGFloat {
    func roundToPlaces(places:Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return round(self * divisor) / divisor
    }
}