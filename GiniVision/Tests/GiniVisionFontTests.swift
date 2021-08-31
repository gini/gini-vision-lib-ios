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
    
    func testRegularDynamicFontGeneration() {
        if #available(iOS 11.0, *) {
            let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.regular)
            XCTAssertEqual(dynamicFont, font.with(weight: .regular, size: 14, style: .body))
        }
    }
    
    func testBoldDynamicFontGeneration() {
        if #available(iOS 12.0, *) {
            let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.bold)
            XCTAssertEqual(dynamicFont, font.with(weight: .bold, size: 14, style: .body))
        }
    }
    
    func testThinDynamicFontGeneration() {
        if #available(iOS 11.0, *) {
            let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.thin)
            XCTAssertEqual(dynamicFont, font.with(weight: .thin, size: 14, style: .body))
        }
    }
    
    func testLightDynamicFontGeneration() {
        if #available(iOS 11.0, *) {
            let dynamicFont = UIFontMetrics(forTextStyle: .body).scaledFont(for: font.light)
            XCTAssertEqual(dynamicFont, font.with(weight: .light, size: 14, style: .body))
        }
    }
    
}
