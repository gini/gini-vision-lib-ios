//
//  PartialDocumentInfo.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/5/18.
//

import Foundation

struct PartialDocumentInfo {
    
    let document: String
    let additionalParameters: [String: Any]?
}

// TODO: Remove when updating to Swift 4.1
extension PartialDocumentInfo {
    func toJson() -> [String: Any] {
        var dict = additionalParameters ?? [:]
        dict["document"] = document
       
        return dict
    }
}
