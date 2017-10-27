import XCTest

class GINICameraUITests: XCTestCase {
    
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
    
    func testCameraIsPresent() {
        app.buttons["Screen API"].tap()
        
        let captureButton = app.buttons["Auslösen"]
        XCTAssert(captureButton.exists, "capture button should exist indicating that the library was started correctly and is presenting the camera screen on start")
    }
    
    func testCapture() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        let reviewScreen = app.navigationBars["Überprüfen"]
        _ = reviewScreen.waitForExistence(timeout: 5)
        
        XCTAssert(reviewScreen.exists, "taping the capture button should trigger displaying the review screen")
    }
    
}
