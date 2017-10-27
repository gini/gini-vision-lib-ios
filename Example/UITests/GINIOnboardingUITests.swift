import XCTest

class GINIOnboardingUITests: XCTestCase {
    
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
    
    func testScreenAPILaunchAndClose() {        
        let screenAPIButton = app.buttons["Screen API"]
        screenAPIButton.tap()
        
        let closeButton = app.navigationBars["Dokument fotografieren"].buttons["Schließen"]
        closeButton.tap()
        
        XCTAssert(screenAPIButton.exists, "should be back to launch screen including the screen api launch button")
    }
    
}
