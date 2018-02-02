//
//  Int.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation

internal extension Int {
    static func indexesBetween(_ first: Int, and second: Int) -> [Int] {
        var indexes: [Int] = []
        let maxInt: Int = Swift.max(first, second)
        let minInt: Int = Swift.min(first, second)
        
        for index in (minInt+1)..<maxInt {
            indexes.append(index)
        }
        return indexes
    }
}
