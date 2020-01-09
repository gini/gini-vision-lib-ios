//
//  Price.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

struct Price {
    
    let valueInFractionalUnit: Int
    
    var mainUnitComponentString: String {
        
        return "€\(valueInFractionalUnit/100)"
    }
    
    var fractionalUnitComponentString: String {
                
        let cents = valueInFractionalUnit - (valueInFractionalUnit/100) * 100
        return "." + (cents < 10 ? "0\(cents)" : "\(cents)")
    }
}
