//
//  GiniVisionFontTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 1/23/19.
//

import XCTest
@testable import GiniVision

final class GiniVisionFontTests: XCTestCase {

    let font = GiniVisionFont(regular: UIFont.systemFont(ofSize: 14, weight: .regular),
                              bold: UIFont.systemFont(ofSize: 14, weight: .bold),
                              light: UIFont.systemFont(ofSize: 14, weight: .light),
                              thin: UIFont.systemFont(ofSize: 14, weight: .thin),
                              isEnabled: false)
    
    override func setUp() {
        super.setUp()
    }
    
    @available(iOS 11.0, *)
    func testRegularDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.regular)
        
        XCTAssertEqual(dynamicFont, font.with(.regular, size: 14, style: .body))
    }
    
    @available(iOS 11.0, *)
    func testBoldDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.bold)
        
        XCTAssertEqual(dynamicFont, font.with(.bold, size: 14, style: .body))
    }
    
    @available(iOS 11.0, *)
    func testThinDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.thin)
        
        XCTAssertEqual(dynamicFont, font.with(.thin, size: 14, style: .body))
    }
    
    @available(iOS 11.0, *)
    func testLightDynamicFontGeneration() {
        let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.light)
        
        XCTAssertEqual(dynamicFont, font.with(.light, size: 14, style: .body))
    }
    
}
