//
//  DocumentRequest.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/12/18.
//

import Foundation

public struct DocumentRequest {
    public var document: GiniVisionDocument
    public var error: Error?
    public var isUploaded = false

    public init(value: GiniVisionDocument, error: Error? = nil, isUploaded: Bool = false) {
        self.document = value
        self.error = error
        self.isUploaded = isUploaded
    }
}
