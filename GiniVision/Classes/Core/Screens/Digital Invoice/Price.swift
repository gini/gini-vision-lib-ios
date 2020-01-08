//
//  Price.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

struct Price {
    
    static let zero = Price(valueInFractionalUnit: 0)
    
    let valueInFractionalUnit: Int
    
    init(valueInFractionalUnit: Int) {
        self.valueInFractionalUnit = valueInFractionalUnit
    }
    
    init?(string: String) {
       
        guard let decimal = Decimal(string: string) else { return nil }
        
        valueInFractionalUnit = NSDecimalNumber(decimal: decimal * Decimal(100)).intValue
    }
    
    var string: String {
        let sign = valueInFractionalUnit < 0 ? "-" : ""
        return "\(sign)\(abs(valueInFractionalUnit)/100)\(fractionalUnitComponentString)"
    }
    
    var mainUnitComponentString: String {
        
        return "€\(valueInFractionalUnit/100)"
    }
    
    var fractionalUnitComponentString: String {
                
        let cents = abs(valueInFractionalUnit) - (abs(valueInFractionalUnit)/100) * 100
        return "." + (cents < 10 ? "0\(cents)" : "\(cents)")
    }
}

extension Price: Equatable {
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.valueInFractionalUnit == rhs.valueInFractionalUnit
    }
}

extension Price {
    
    static func *(price: Price, int: Int) -> Price {
        return Price(valueInFractionalUnit: price.valueInFractionalUnit * int)
    }
    
    static func +(lhs: Price, rhs: Price) -> Price {
        return Price(valueInFractionalUnit: lhs.valueInFractionalUnit + rhs.valueInFractionalUnit)
    }
}
