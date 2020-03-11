//
//  Price.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

struct Price {
        
    let value: Decimal
    let currencyCode: String
    
    init(value: Decimal, currencyCode: String) {
        self.value = value
        self.currencyCode = currencyCode
    }
    
    init?(extractionString: String) {
       
        let components = extractionString.components(separatedBy: ":")
        
        guard components.count == 2 else { return nil }
        
        guard let decimal = Decimal(string: components.first ?? ""),
            let currencyCode = components.last?.lowercased() else {
                return nil
        }
        
        self.value = decimal
        self.currencyCode = currencyCode
    }
    
    var extractionString: String {
        return "\(value):\(currencyCode)"
    }
    
    var string: String? {
        
        let formatter = NumberFormatter()
        formatter.currencyCode = currencyCode
        formatter.numberStyle = .currency
        return formatter.string(from: NSDecimalNumber(decimal: value))
    }
    
    var stringWithoutSymbol: String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSDecimalNumber(decimal: value))
    }
}

extension Price: Equatable {}

extension Price {
    
    static func *(price: Price, int: Int) -> Price {
        
        return Price(value: price.value * Decimal(int),
                     currencyCode: price.currencyCode)
    }
    
    struct PriceCurrencyMismatchError: Error {}
    
    static func +(lhs: Price, rhs: Price) throws -> Price {
        
        if lhs.currencyCode != rhs.currencyCode {
            throw PriceCurrencyMismatchError()
        }
        
        return Price(value: lhs.value + rhs.value,
                     currencyCode: lhs.currencyCode)
    }
}
