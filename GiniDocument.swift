//
//  GiniDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

@objc public protocol GiniDocument:class {
    var type:GiniDocumentType { get }
    init(data:Data)
}

@objc public enum GiniDocumentType:Int {
    case PDF = 0
    case Image = 1
}
