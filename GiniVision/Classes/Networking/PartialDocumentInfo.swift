//
//  PartialDocumentInfo.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 5/3/18.
//

import Gini_iOS_SDK

struct PartialDocumentInfo {
    let info: GINIPartialDocumentInfo
    var order: Int
}

extension PartialDocumentInfo: Comparable {
    static func == (lhs: PartialDocumentInfo, rhs: PartialDocumentInfo) -> Bool {
        return lhs.info.documentUrl == rhs.info.documentUrl
    }
    
    static func < (lhs: PartialDocumentInfo, rhs: PartialDocumentInfo) -> Bool {
        return lhs.order < rhs.order
    }
}
