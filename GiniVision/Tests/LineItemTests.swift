//
//  LineItemTests.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 26.02.20.
//

import XCTest
@testable import GiniVision
@testable import Gini

class LineItemTests: XCTestCase {
    
    let lineItem: DigitalInvoice.LineItem = {
        
        let lineItemBox = Extraction.Box(height: 9.0, left: 72.0, page: 1, top: 347.11, width: 5.0)
        
        return try! DigitalInvoice.LineItem(extractions: [
            Extraction(box: lineItemBox, candidates: nil, entity: "amount", value: "39.99:EUR", name: "baseGross"),
            Extraction(box: nil, candidates: nil, entity: "text", value: "CORE ICON - Sweatjacke - emerald", name: "description"),
            Extraction(box: nil, candidates: nil, entity: "idnumber", value: "H0422S039-M11000L000", name: "artNumber"),
            Extraction(box: nil, candidates: nil, entity: "number", value: "3", name: "quantity")
        ])
    }()
    
    func testInit() throws {
        
        XCTAssertEqual(lineItem.name, "CORE ICON - Sweatjacke - emerald")
        XCTAssertEqual(lineItem.price, Price(value: Decimal(string: "39.99")!, currencyCode: "eur"))
        XCTAssertEqual(lineItem.quantity, 3)
        
        switch lineItem.selectedState {
        case .selected:
            break
        case.deselected:
            XCTFail("Default selected state on a line item should be .selected")
        }
    }
    
    func testTotalPrice() {
        
        XCTAssertEqual(lineItem.totalPrice, Price(value: Decimal(string: "119.97")!, currencyCode: "eur"))
    }
}
