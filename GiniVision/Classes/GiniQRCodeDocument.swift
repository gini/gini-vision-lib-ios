//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

@objc final public class GiniQRCodeDocument: NSObject, GiniVisionDocument {
    public var type: GiniVisionDocumentType = .qrcode
    public var data: Data
    public lazy var previewImage: UIImage? = {
        return generateQRCodeImage(from: self.data)
    }()
    public var isReviewable: Bool = false
    public var isImported: Bool = false
    public lazy var extractedParameters: [String: String] = self.extractParameters(from: self.scannedString)
    
    fileprivate let scannedString: String
    fileprivate let epc06912LinesCount = 12
    fileprivate lazy var qrCodeFormat: QRCodesFormat? = {
        if self.scannedString.starts(with: "bank://") {
            return .bezahlcode
        } else {
            let lines = self.scannedString.splitlines
            if lines.count > 9 &&
                (lines[1] == "001" || lines[1] == "002") &&
                (lines[2] == "1" || lines[2] == "2") {
                return .epc06912
            }
            return nil
        }
    }()
    
    fileprivate enum QRCodesFormat {
        case epc06912
        case bezahlcode
    }
    
    public init(scannedString: String) {
        self.data = scannedString.data(using: String.Encoding.isoLatin1) ?? Data(count: 0)
        self.scannedString = scannedString
        super.init()
    }
    
    public func checkType() throws {
        if self.qrCodeFormat == nil || self.extractedParameters.isEmpty {
            throw DocumentValidationError.qrCodeFormatNotValid
        }
    }
}

// MARK: Equatable

extension GiniQRCodeDocument {
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? GiniQRCodeDocument {
            return self.scannedString == object.scannedString
        }
        return false
    }
}

// MARK: Extractions

extension GiniQRCodeDocument {
    fileprivate func extractParameters(from string: String) -> [String: String] {
        switch qrCodeFormat {
        case .some(.bezahlcode):
            return extractParameters(fromBezhalCodeString: string)
        case .some(.epc06912):
            return extractParameters(fromEPC06912CodeString: string)
        case .none:
            return [:]
        }
    }
    
    fileprivate func extractParameters(fromBezhalCodeString string: String) -> [String: String] {
        var parameters: [String: String] = [:]
        
        if let queryParameters = URL(string: string)?.queryParameters {
            
            if let bic = queryParameters["bic"] as? String {
                parameters["bic"] = bic
            }
            if let paymentRecipient = queryParameters["name"] as? String {
                parameters["paymentRecipient"] = paymentRecipient
            }
            if let iban = queryParameters["iban"] as? String,
                IBANValidator().isValid(iban: iban) {
                parameters["iban"] = iban
            }
            if let paymentReference = queryParameters["reason"] as? String ??
                queryParameters["reason1"] as? String {
                parameters["paymentReference"] = paymentReference
            }
            if let amount = queryParameters["amount"] as? String,
                let amountNormalized = normalize(amount: amount,
                                                 currency: queryParameters["currency"] as? String ?? "EUR") {
                parameters["amountToPay"] = amountNormalized
            }
        }
        
        return parameters
    }
    
    fileprivate func extractParameters(fromEPC06912CodeString string: String) -> [String: String] {
        let lines = string.splitlines
        var parameters: [String: String] = [:]
        
        if !lines[4].isEmpty {
            parameters["bic"] = lines[4]
        }
        
        if !lines[5].isEmpty {
            parameters["paymentRecipient"] = lines[5]
        }
        
        if !lines[9].isEmpty {
            parameters["paymentReference"] = lines[9]
        }
        
        if IBANValidator().isValid(iban: lines[6]) {
            parameters["iban"] = lines[6]
        }
        
        if let amountToPay = normalize(amount: lines[7], currency: nil) {
            parameters["amountToPay"] = amountToPay
        }
        
        return parameters
    }
    
    fileprivate func normalize(amount: String, currency: String?) -> String? {
        let regexCurrency = try? NSRegularExpression(pattern: "[aA-zZ]", options: [])
        let length = amount.count < 3 ? amount.count : 3
        
        if regexCurrency?.numberOfMatches(in: amount, options: [], range: NSRange(location: 0, length: length)) == 3 {
            let currency = amount.substring(to: String.Index(encodedOffset: 3))
            let quantity = amount.substring(from: String.Index(encodedOffset: 3))
            return quantity + ":" + currency
        } else if let currency = currency {
            return amount + ":" + currency
        }
        
        return nil
    }
}
