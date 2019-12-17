//
//  DigitalInvoiceTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Maciej Trybilo on 17.12.19.
//

import XCTest
@testable import GiniVision

let digitalInvoiceEmpty = DigitalInvoice(recipientName: "Someone",
                                         iban: "DEBLABLABLA",
                                         reference: "BLAbla",
                                         lineItems: [])

let digitalInvoiceExample = DigitalInvoice(recipientName: "Someone",
                                           iban: "DE13839348034993839",
                                           reference: "ODIJ0IEJWSJ9IJ",
                                           lineItems: [DigitalInvoice.LineItem(name: "Nike Sportswear Air Max 97 - Sneaker",
                                                                               quantity: 3,
                                                                               price: 7648,
                                                                               selectedState: .selected),
                                                       DigitalInvoice.LineItem(name: "Nike Sportswear INTERNATIONALIST",
                                                                               quantity: 1,
                                                                               price: 15295,
                                                                               selectedState: .deselected(reason: .damaged)),
                                                       DigitalInvoice.LineItem(name: "Erbauer EPT1500 254 Planer/Thicknesser",
                                                                               quantity: 1,
                                                                               price: 22000,
                                                                               selectedState: .deselected(reason: .damaged)),
                                                       DigitalInvoice.LineItem(name: "Erbauer EPT1500 254 Planer/Thicknesser",
                                                                               quantity: 1,
                                                                               price: 22000,
                                                                               selectedState: .deselected(reason: .damaged)),
                                                       DigitalInvoice.LineItem(name: "Brace & Bit",
                                                                               quantity: 3,
                                                                               price: 8993,
                                                                               selectedState: .selected),
                                                       DigitalInvoice.LineItem(name: "Brace & Bit",
                                                                               quantity: 3,
                                                                               price: 8993,
                                                                               selectedState: .selected)])

class DigitalInvoiceTests: XCTestCase {
    
    func testTotal() {
        
        XCTAssertEqual(digitalInvoiceEmpty.total, 0)
        XCTAssertEqual(digitalInvoiceExample.total, 76902)
    }
    
    func testNumSelected() {
        
        XCTAssertEqual(digitalInvoiceEmpty.numSelected, 0)
        XCTAssertEqual(digitalInvoiceExample.numSelected, 9)
    }
    
    func testNumTotal() {
        
        XCTAssertEqual(digitalInvoiceEmpty.numTotal, 0)
        XCTAssertEqual(digitalInvoiceExample.numTotal, 12)
    }
}
