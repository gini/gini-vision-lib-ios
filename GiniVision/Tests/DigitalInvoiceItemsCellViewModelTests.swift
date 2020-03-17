//
//  DigitalInvoiceItemsCellViewModelTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Maciej Trybilo on 17.12.19.
//

import XCTest
@testable import GiniVision

class DigitalInvoiceItemsCellViewModelTests: XCTestCase {

    func testItemsLabelText() {
        
        XCTAssertEqual(DigitalInvoiceItemsCellViewModel(invoice: digitalInvoiceExample).itemsLabelText, "Items 6/9")
    }
}