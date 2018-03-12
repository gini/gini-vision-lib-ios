//
//  Collection.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

internal extension Collection where Iterator.Element == CFString {
    
    var strings: [ String ] {
        return self.map { $0 as String }
    }
    
}

extension Collection where Iterator.Element == GiniVisionDocument {
    var containsDifferentTypes: Bool {        
        if let firstElement = first {
            let otherTypes = filter { $0.type != firstElement.type }
            return otherTypes.isNotEmpty
        }
        
        return true
    }

    var type: GiniVisionDocumentType? {
        return containsDifferentTypes ? nil : first?.type
    }
    
}
