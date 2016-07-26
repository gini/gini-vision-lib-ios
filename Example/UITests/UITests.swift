import XCTest

class GiniVision_UITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        XCUIApplication().launch()
        // TODO: First launch fix
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testScreenAPILaunchAndClose() {
        let app = XCUIApplication()
        
        let screenAPIButton = app.buttons["Screen API"]
        screenAPIButton.tap()
        
        let closeButton = app.navigationBars["Fotoüberweisung"].childrenMatchingType(.Button).elementBoundByIndex(0)
        closeButton.tap()
        
        XCTAssert(screenAPIButton.exists, "should be back to launch screen including the screen api launch button")
    }
    
    func testScreenAPIShowAndHideOnboarding() {
        let app = XCUIApplication()
        
        let screenAPIButton = app.buttons["Screen API"]
        screenAPIButton.tap()
        
        let helpButton = app.navigationBars["Fotoüberweisung"].buttons["Hilfe"]
        helpButton.tap()
        
        let continueButton = app.navigationBars["Anleitung"].buttons["Weiter"]
        
        // This works, because Onboarding should be dismissed when the last page is reached. ;)
        while continueButton.exists {
            continueButton.tap()
        }
        
        XCTAssert(helpButton.exists, "should be back to camera screen")
    }
    
    func test() {
        let app = XCUIApplication()
        
        // TODO: Evaluate how to make use of `accessibilityIdentifier` on UIKit elements to avoid customization or localization problems
        let screenAPIButton = app.buttons.matchingIdentifier("gotcha").element
        XCTAssert(screenAPIButton.exists)
    }
    
}