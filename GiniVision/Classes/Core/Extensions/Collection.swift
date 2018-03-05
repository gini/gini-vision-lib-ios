//
//  Collection.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

internal extension Collection where Iterator.Element == CFString {
    
    var strings: [ String ] {
        return self.map { $0 as String }
    }
    
}

extension Collection where Iterator.Element == GiniVisionDocument {
    var isAssorted: Bool {
        var result: [GiniVisionDocument] = []
        
        for document in self {
            if result.isEmpty {
                result.append(document)
            } else if let last = result.last, last.type == document.type {
                result.append(document)
            } else {
                return true
            }
        }
        
        return result.count == count
    }
}
