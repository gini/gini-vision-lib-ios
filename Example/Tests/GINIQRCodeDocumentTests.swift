//
//  GINIQRCodeDocumentTests.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GINIQRCodeDocumentTests: XCTestCase {
    
    func testBezahlQRCodeExtractions() {
        let qrDocument = GiniQRCodeDocument(scannedString: "bank://singlepaymentsepa?name=Gini%20Online%20Shop" +
            "&reason=A12345-6789&iban=DE89370400440532013000&bic=GINIBICXXX&amount=47%2C65&currency=EUR")
        XCTAssertNoThrow(try qrDocument.validate(), "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"] as? String, "47,65:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"] as? String, "Gini Online Shop",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"] as? String, "A12345-6789",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"] as? String, "DE89370400440532013000",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"] as? String, "GINIBICXXX",
                       "bic should match")
    }
    
    func testEPC06912QRCodeExtractions() {
        let scannedString = "BCD\n001\n2\nSCT\nGENODEF1KIL\nMax Mustermann\nDE52210900070088299309\n" +
            "EUR1456.89\n\n457845789452\n\nDiverse Autoteile, Re 789452 KN 457845"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertNoThrow(try qrDocument.validate(), "should throw an error since is valid")
        XCTAssertEqual(qrDocument.extractedParameters["amountToPay"] as? String, "1456.89:EUR",
                       "amountToPay should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentRecipient"] as? String, "Max Mustermann",
                       "paymentRecipient should match")
        XCTAssertEqual(qrDocument.extractedParameters["paymentReference"] as? String, "457845789452",
                       "paymentReference should match")
        XCTAssertEqual(qrDocument.extractedParameters["iban"] as? String, "DE52210900070088299309",
                       "iban should match")
        XCTAssertEqual(qrDocument.extractedParameters["bic"] as? String, "GENODEF1KIL",
                       "bic should match")

    }
    
    func testNotValidQRCodeFormat() {
        let qrDocument = GiniQRCodeDocument(scannedString: "invalidQRCodeFormat")
        XCTAssertThrowsError(try qrDocument.validate()) { error in
            XCTAssertTrue(error as? DocumentValidationError == DocumentValidationError.qrCodeFormatNotValid,
                          "validation should throw a DocumentaValidationError")
        }
    }
    
    func testNotValidEPC06912QRCodeFormat() {
        let scannedString = "1\n003\n3\nSCT\n5\n6\n7\n8\n9\n10\n11"
        let qrDocument = GiniQRCodeDocument(scannedString: scannedString)
        XCTAssertThrowsError(try qrDocument.validate(),
                             "validation should throw a DocumentaValidationError")
    }
}
