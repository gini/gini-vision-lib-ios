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
        app.navigationBars["Dokument überprüfen"].buttons["Weiter"].tap()
        
        let analysisNavigationBar = app.navigationBars["Dokument analysieren"]
        XCTAssert(analysisNavigationBar.exists, "navigation bar with title 'Dokument analysieren' should be displayed")
    }
    
    func testShowAndHideErrorMessage() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        app.navigationBars["Dokument überprüfen"].buttons["Weiter"].tap()
        
        let error = app.staticTexts["My network error"]
        XCTAssert(error.exists, "error label should exist displaying a custom error message")
        
        error.tap()
        XCTAssert(!error.exists, "error label should be dismissed when tapped")
    }
    
}