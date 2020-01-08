//
//  PriceTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Maciej Trybilo on 08.01.20.
//

import XCTest
@testable import GiniVision

final class PriceTests: XCTestCase {

    func testZero() {
        
        XCTAssertEqual(Price.zero.valueInFractionalUnit, 0)
    }
    
    func testValueInit() {
        
        XCTAssertEqual(Price(valueInFractionalUnit: 98).valueInFractionalUnit, 98)
    }
    
    func testStringInit() {
        
        XCTAssertEqual(Price(string: "0")?.valueInFractionalUnit, 0)
        XCTAssertEqual(Price(string: "-0")?.valueInFractionalUnit, 0)
        XCTAssertEqual(Price(string: "12.34")?.valueInFractionalUnit, 1234)
        XCTAssertEqual(Price(string: "-12.34")?.valueInFractionalUnit, -1234)
        XCTAssertEqual(Price(string: "12.30")?.valueInFractionalUnit, 1230)
        XCTAssertEqual(Price(string: "12.3")?.valueInFractionalUnit, 1230)
        XCTAssertEqual(Price(string: "12.34bloop")?.valueInFractionalUnit, 1234)
        XCTAssertNil(Price(string: ""))
        XCTAssertNil(Price(string: "bloop"))
    }
    
    func testString() {
        
        XCTAssertEqual(Price(valueInFractionalUnit: 1234).string, "12.34")
        XCTAssertEqual(Price(valueInFractionalUnit: 0).string, "0.00")
        XCTAssertEqual(Price(valueInFractionalUnit: -1234).string, "-12.34")
        XCTAssertEqual(Price(valueInFractionalUnit: 1230).string, "12.30")
        XCTAssertEqual(Price(valueInFractionalUnit: 1204).string, "12.04")
        XCTAssertEqual(Price(valueInFractionalUnit: 2).string, "0.02")
        XCTAssertEqual(Price(valueInFractionalUnit: 20).string, "0.20")
        XCTAssertEqual(Price(valueInFractionalUnit: -2).string, "-0.02")
        XCTAssertEqual(Price(valueInFractionalUnit: -20).string, "-0.20")
    }
    
    func testMainUnitComponentString() {
        
        XCTAssertEqual(Price(valueInFractionalUnit: 1234).mainUnitComponentString, "€12")
        XCTAssertEqual(Price(valueInFractionalUnit: 0).mainUnitComponentString, "€0")
        XCTAssertEqual(Price(valueInFractionalUnit: -1234).mainUnitComponentString, "€-12")
        XCTAssertEqual(Price(valueInFractionalUnit: 1230).mainUnitComponentString, "€12")
        XCTAssertEqual(Price(valueInFractionalUnit: 1204).mainUnitComponentString, "€12")
        XCTAssertEqual(Price(valueInFractionalUnit: 2).mainUnitComponentString, "€0")
        XCTAssertEqual(Price(valueInFractionalUnit: 20).mainUnitComponentString, "€0")
        XCTAssertEqual(Price(valueInFractionalUnit: -2).mainUnitComponentString, "€0")
        XCTAssertEqual(Price(valueInFractionalUnit: -20).mainUnitComponentString, "€0")
    }
    
    func testFractionalUnitComponentString() {
        
        XCTAssertEqual(Price(valueInFractionalUnit: 1234).fractionalUnitComponentString, ".34")
        XCTAssertEqual(Price(valueInFractionalUnit: 0).fractionalUnitComponentString, ".00")
        XCTAssertEqual(Price(valueInFractionalUnit: -1234).fractionalUnitComponentString, ".34")
        XCTAssertEqual(Price(valueInFractionalUnit: 1230).fractionalUnitComponentString, ".30")
        XCTAssertEqual(Price(valueInFractionalUnit: 1204).fractionalUnitComponentString, ".04")
        XCTAssertEqual(Price(valueInFractionalUnit: 2).fractionalUnitComponentString, ".02")
        XCTAssertEqual(Price(valueInFractionalUnit: 20).fractionalUnitComponentString, ".20")
        XCTAssertEqual(Price(valueInFractionalUnit: -2).fractionalUnitComponentString, ".02")
        XCTAssertEqual(Price(valueInFractionalUnit: -20).fractionalUnitComponentString, ".20")
    }
    
    func testMultiplicationWithInt() {
        
        XCTAssertEqual(Price(valueInFractionalUnit: 0) * 0, Price(valueInFractionalUnit: 0))
        XCTAssertEqual(Price(valueInFractionalUnit: 100) * 0, Price(valueInFractionalUnit: 0))
        XCTAssertEqual(Price(valueInFractionalUnit: 2) * 4, Price(valueInFractionalUnit: 8))
    }
    
    func testAddition() {
        
        XCTAssertEqual(Price(valueInFractionalUnit: 0) + Price(valueInFractionalUnit: 0), Price(valueInFractionalUnit: 0))
        XCTAssertEqual(Price(valueInFractionalUnit: 1) + Price(valueInFractionalUnit: 2), Price(valueInFractionalUnit: 3))
    }
}
