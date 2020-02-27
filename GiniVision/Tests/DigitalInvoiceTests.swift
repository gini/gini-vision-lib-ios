//
//  DigitalInvoiceTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Maciej Trybilo on 17.12.19.
//

import XCTest
@testable import GiniVision
@testable import Gini

let digitalInvoiceExample: DigitalInvoice = {
    
    let lineItemBox = Extraction.Box(height: 9.0, left: 72.0, page: 1, top: 347.11, width: 5.0)
    
    var invoice = try! DigitalInvoice(extractionResult: ExtractionResult(extractions: [
        
        Extraction(box: Extraction.Box(height: 9.0, left: 516.0, page: 1, top: 588.0, width: 42.0),
                   candidates: nil, entity: "amount", value: "24.99:EUR", name: "amountToPay")
        
        ], lineItems: [
            [
                Extraction(box: lineItemBox, candidates: nil, entity: "amount", value: "39.99:EUR", name: "grossPrice"),
                Extraction(box: nil, candidates: nil, entity: "text", value: "CORE ICON - Sweatjacke - emerald", name: "description"),
                Extraction(box: nil, candidates: nil, entity: "idnumber", value: "H0422S039-M11000L000", name: "artNumber"),
                Extraction(box: nil, candidates: nil, entity: "number", value: "3", name: "quantity")
            ],
            [
                Extraction(box: nil, candidates: nil, entity: "amount", value: "34.99:EUR", name: "grossPrice"),
                Extraction(box: nil, candidates: nil, entity: "text", value: "Strickpullover - yellow", name: "description"),
                Extraction(box: nil, candidates: nil, entity: "idnumber", value: "YO122Q047-E11000L000", name: "artNumber"),
                Extraction(box: nil, candidates: nil, entity: "number", value: "1", name: "quantity")
            ],
            [
                Extraction(box: nil, candidates: nil, entity: "amount", value: "49.99:EUR", name: "grossPrice"),
                Extraction(box: nil, candidates: nil, entity: "text", value: "JPRDEEP CREW NECK - Strickpullover - vintage indigo", name: "description"),
                Extraction(box: nil, candidates: nil, entity: "idnumber", value: "JAM22Q01E-K11000L000", name: "artNumber"),
                Extraction(box: nil, candidates: nil, entity: "number", value: "5", name: "quantity")
            ]
    ]))
    
    var lineItem1 = invoice.lineItems.first!
    lineItem1.selectedState = .deselected(reason: .arrivedTooLate)
    
    invoice.lineItems[0] = lineItem1
        
    return invoice
}()

class DigitalInvoiceTests: XCTestCase {
    
    func testInit() {
        XCTAssertThrowsError(try DigitalInvoice(extractionResult: ExtractionResult(extractions: [], lineItems: nil)))
    }
    
    func testTotal() {
        XCTAssertEqual(digitalInvoiceExample.total, Price(value: 284.94, currencyCode: "eur") )
    }
    
    func testNumSelected() {
        
        XCTAssertEqual(digitalInvoiceExample.numSelected, 6)
    }
    
    func testNumTotal() {
        
        XCTAssertEqual(digitalInvoiceExample.numTotal, 9)
    }
    
    func testExtractionResultPreservesExtractions() {
        
        let extractionResult = digitalInvoiceExample.extractionResult
        
        XCTAssertEqual(extractionResult.extractions.count, 1)
        XCTAssertEqual(extractionResult.extractions.first!, Extraction(box: Extraction.Box(height: 9.0,
                                                                                           left: 516.0,
                                                                                           page: 1,
                                                                                           top: 588.0,
                                                                                           width: 42.0),
                                                                       candidates: nil,
                                                                       entity: "amount",
                                                                       value: "24.99:EUR",
                                                                       name: "amountToPay"))
        
        XCTAssertEqual(extractionResult.lineItems!.count, 3)
        XCTAssertEqual(extractionResult.lineItems!.first!.first!.box, Extraction.Box(height: 9.0, left: 72.0, page: 1, top: 347.11, width: 5.0))
    }
}
