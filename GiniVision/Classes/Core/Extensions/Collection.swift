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
