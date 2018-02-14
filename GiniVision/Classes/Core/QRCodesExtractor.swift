//
//  QRCodeExtractor.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/8/17.
//

import Foundation

enum QRCodesFormat {
    case epc06912
    case bezahlcode
}

final class QRCodesExtractor {
    class func extractParameters(from string: String, withFormat qrCodeFormat: QRCodesFormat?) -> [String: String] {
        switch qrCodeFormat {
        case .some(.bezahlcode):
            return extractParameters(fromBezhalCodeString: string)
        case .some(.epc06912):
            return extractParameters(fromEPC06912CodeString: string)
        case .none:
            return [:]
        }
    }
    
    class func extractParameters(fromBezhalCodeString string: String) -> [String: String] {
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
    
    class func extractParameters(fromEPC06912CodeString string: String) -> [String: String] {
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
    
    fileprivate class func normalize(amount: String, currency: String?) -> String? {
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
