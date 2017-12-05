//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

final public class GiniQRCodeDocument: GiniVisionDocument {
    public var type: GiniVisionDocumentType = .qrcode
    public var data: Data
    public var previewImage: UIImage?
    public var isReviewable: Bool = false
    public var isImported: Bool = false
    
    public let scannedString: String
    public var extractedParameters: [String: Any] = [:]
    fileprivate var qrCodeFormat: QRCodesFormat?
    fileprivate let epc06912LinesCount = 12
    
    fileprivate enum QRCodesFormat {
        case epc06912
        case bezahlcode
    }
    
    public init(scannedString: String) {
        self.data = scannedString.data(using: String.Encoding.utf8) ?? Data(count: 0)
        self.scannedString = scannedString
        self.qrCodeFormat = qrCodeFormatFrom(string: scannedString)
        self.extractedParameters = extractParameters(forString: scannedString)
    }
    
    public func checkType() throws {
        if self.qrCodeFormat == nil {
            throw DocumentValidationError.qrCodeFormatNotValid
        }
    }
    
    fileprivate func qrCodeFormatFrom(string: String) -> QRCodesFormat? {
        if string.starts(with: "bank://") {
            return .bezahlcode
        } else {
            return string.splitlines.count == epc06912LinesCount ? .epc06912 : nil
        }
    }
    
    fileprivate func extractParameters(forString string: String) -> [String: Any] {
        switch qrCodeFormat {
        case .some(.bezahlcode):
            if let queryParameters = URL(string: string)?.queryParameters {
                var parameters: [String: Any] = [:]
                
                if let bic = queryParameters["bic"] {
                    parameters["bic"] = bic
                }
                if let paymentRecipient = queryParameters["name"] {
                    parameters["paymentRecipient"] = paymentRecipient
                }
                if let iban = queryParameters["iban"] as? String,
                    IBANValidator().isValid(iban: iban) {
                    parameters["iban"] = iban
                }
                if let paymentReference = queryParameters["reason"] {
                    parameters["paymentReference"] = paymentReference
                }
                if let amount = queryParameters["amount"] as? String,
                    let currency = queryParameters["currency"] as? String,
                    let amountNormalized = normalize(amount: amount, currency: currency) {
                    parameters["amountToPay"] = amountNormalized
                }
                
                return parameters
            }

            return [:]
        case .some(.epc06912):
            let lines = string.splitlines
            var parameters: [String: Any] = [
                "bic": lines[4],
                "paymentRecipient": lines[5],
                "paymentReference": lines[9]
            ]
            
            if IBANValidator().isValid(iban: lines[6]) {
                parameters["iban"] = lines[6]
            }
            
            if let amountToPay = normalize(amount: lines[7], currency: nil) {
                parameters["amountToPay"] = amountToPay
            }
            
            return parameters
        case .none:
            return [:]
        }
    }
    
    fileprivate func normalize(amount: String, currency: String?) -> String? {
        let regexCurrency = try? NSRegularExpression(pattern: "[aA-zZ]", options: [])
        
        if let matches = regexCurrency?.matches(in: amount, options: [], range: NSRange(location: 0, length: 3)),
            matches.count == 3 {
            let currency = amount.substring(to: String.Index(encodedOffset: 3))
            let quantity = amount.substring(from: String.Index(encodedOffset: 3))
            return quantity + ":" + currency
        } else if let currency = currency {
            return amount + ":" + currency
        }
       
        return nil
    }
    
}
