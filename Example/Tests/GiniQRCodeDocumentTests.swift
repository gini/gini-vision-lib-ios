//
//  GiniQRCodeDocumentTests.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GiniQRCodeDocumentTests: XCTestCase {
    
    let giniConfiguration: GiniConfiguration = GiniConfiguration()
    
    func testBezahlQRCodeExtractions() {
        let qrDocument = GiniQRCodeDocument(scannedString: "bank://singlepaymentsepa?name=Gini%20Online%20Shop" +
            "&reason=A12345-6789&iban=DE89370400440532013000&bic=GINIBICXXX&amount=47%2C65&currency=EUR")
        XCTAssertNoThrow(try GiniVisionDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "47,65:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "Gini Online Shop",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "A12345-6789",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE89370400440532013000",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GINIBICXXX",
                       "bic should match")
    }
    
    func testEPC06912QRCodeExtractions() {
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\n" +
            "EUR1456.89\n\n457845789452\n\nDiverse Autoteile, Re 789452 KN 457845"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try GiniVisionDocumentValidator.validate(qrDocument,
                                                                  withConfig: giniConfiguration),
                         "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"], "1456.89:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"], "Max Mustermann",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"], "457845789452",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"], "DE52210900070088299309",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"], "GENODEF1KIL",
                       "bic should match")

    }
    
    func testNotValidQRCodeFormat() {
        let qrDocument = GiniQRCodeDocument(scannedString: "invalidQRCodeFormat")
        XCTAssertThrowsError(try GiniVisionDocumentValidator.validate(qrDocument,
                                                                      withConfig: giniConfiguration)) { error in
            XCTAssertTrue(error as? DocumentValidationError == DocumentValidationError.qrCodeFormatNotValid,
                          "validation should throw a DocumentaValidationError")
        }
    }
    
    func testNotValidEPC06912QRCodeFormat() {
        let scannedString = "1\n003\n3\nSCT\n5\n6\n7\n8\n9\n10\n11"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertThrowsError(try GiniVisionDocumentValidator.validate(qrDocument,
                                                                      withConfig: giniConfiguration),
                             "validation should throw a DocumentaValidationError")
    }
}
