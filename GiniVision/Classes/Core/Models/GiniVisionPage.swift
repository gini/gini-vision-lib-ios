//
//  GiniVisionPage.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/12/18.
//

import Foundation

/**
 Page processed by the _Gini Vision Library_ when using Multipage analysis.
 It holds a document, an error (if any) and if it has been uploaded
 */
public struct GiniVisionPage {
    public var document: GiniVisionDocument
    public var error: Error?
    public var isUploaded = false

    public init(document: GiniVisionDocument, error: Error? = nil, isUploaded: Bool = false) {
        self.document = document
        self.error = error
        self.isUploaded = isUploaded
    }
}
