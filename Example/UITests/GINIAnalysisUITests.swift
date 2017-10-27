import XCTest

class GINIAnalysisUITests: XCTestCase {
    
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
    
    func testAnalysisIsPresent() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        let reviewScreen = app.navigationBars["Überprüfen"]
        _ = reviewScreen.waitForExistence(timeout: 5)
        app.navigationBars["Überprüfen"].buttons["Weiter"].tap()
        
        let analysisScreenLeftButton = app.navigationBars.buttons["Abbrechen"]
        XCTAssert(analysisScreenLeftButton.exists, "navigation bar with title 'Etwas Geduld, analysiere Foto' should be displayed")
    }
    
    func testShowAndHideErrorMessage() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        let reviewScreen = app.navigationBars["Überprüfen"]
        _ = reviewScreen.waitForExistence(timeout: 5)
        app.navigationBars["Überprüfen"].buttons["Weiter"].tap()
        
        let error = app.staticTexts["My network error"]
        XCTAssert(error.exists, "error label should exist displaying a custom error message")
        
        error.tap()
        XCTAssert(!error.exists, "error label should be dismissed when tapped")
    }
    
}
