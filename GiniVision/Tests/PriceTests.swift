//
//  PriceTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Maciej Trybilo on 08.01.20.
//

import XCTest
@testable import GiniVision

final class PriceTests: XCTestCase {
    
    func testValueInit() {
        
        XCTAssertEqual(Price(value: 0.98, currencyCode: "eur").value, 0.98)
    }
    
    func testExtractionStringInit() {
        XCTAssertEqual(Price(extractionString: "0:EUR")?.value, 0)
        XCTAssertEqual(Price(extractionString: "0:EUR")?.currencyCode, "eur")
        XCTAssertEqual(Price(extractionString: "0.45:PLN")?.value, 0.45)
        XCTAssertEqual(Price(extractionString: "0.45:PLN")?.currencyCode, "pln")
        
        XCTAssertEqual(Price(extractionString: "-0:EUR")?.value, 0)
        XCTAssertEqual(Price(extractionString: "12.34:EUR")?.value, 12.34)
        XCTAssertEqual(Price(extractionString: "-12.34:EUR")?.value, -12.34)
        XCTAssertEqual(Price(extractionString: "12.30:EUR")?.value, 12.30)
        XCTAssertEqual(Price(extractionString: "12.3:EUR")?.value, 12.30)
        XCTAssertNil(Price(extractionString: ""))
        XCTAssertNil(Price(extractionString: "bloop"))
    }
    
    func testMultiplicationWithInt() {
        
        XCTAssertEqual(Price(value: 0, currencyCode: "eur") * 0, Price(value: 0, currencyCode: "eur"))
        XCTAssertEqual(Price(value: 100, currencyCode: "eur") * 0, Price(value: 0, currencyCode: "eur"))
        XCTAssertEqual(Price(value: 2, currencyCode: "eur") * 4, Price(value: 8, currencyCode: "eur"))
    }
    
    func testAddition() throws {
        
        XCTAssertEqual(try Price(value: 0, currencyCode: "eur") + Price(value: 0, currencyCode: "eur"), Price(value: 0, currencyCode: "eur"))
        XCTAssertEqual(try Price(value: 1, currencyCode: "eur") + Price(value: 2, currencyCode: "eur"), Price(value: 3, currencyCode: "eur"))
        XCTAssertThrowsError(try Price(value: 23, currencyCode: "eur") + Price(value: 32, currencyCode: "pln"))
    }
}
