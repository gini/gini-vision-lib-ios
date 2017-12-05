//
//  GiniVisionDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

/**
 * Document processed by the _GiniVision_ library.
 */

@objc public protocol GiniVisionDocument: class {
    var type: GiniVisionDocumentType { get }
    var data: Data { get }
    var previewImage: UIImage? { get }
    var isReviewable: Bool { get }
    var isImported: Bool { get }
    
    func checkType() throws
}

// MARK: GiniVisionDocumentType

@objc public enum GiniVisionDocumentType: Int {
    case pdf = 0
    case image = 1
}

// MARK: GiniVisionDocumentBuilder

/**
 The `GiniVisionDocumentBuilder` provides a way to build a `GiniVisionDocument` from a `Data` object.
 The `DocumentSource` must be provided in the initialization, being optional but highly recommended
 setting the `DocumentImportMethod` afterwards. This could be an example of how a `GiniVisionDocument`
 should be built when it has been imported with the _Open with_ feature.
 
 ```swift
 let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
 documentBuilder.importMethod = .openWith
 let document = documentBuilder.build()
 ```
 */
public class GiniVisionDocumentBuilder {
    
    let data: Data?
    var documentSource: DocumentSource
    public var deviceOrientation: UIInterfaceOrientation?
    public var importMethod: DocumentImportMethod?
    
    /**
     Initializes a `GiniVisionDocumentBuilder` with a Data object
     
     - Parameter withData: data object with an unknown type
     
     */
    
    public init(data: Data?, documentSource: DocumentSource) {
        self.data = data
        self.documentSource = documentSource
    }
    
    /**
     Builds a `GiniVisionDocument`
     
     - Returns: A `GiniVisionDocument` if `data` has a valid type or `nil` if it hasn't.
     
     */
    public func build() -> GiniVisionDocument? {
        if let data = data {
            if data.isPDF {
                return GiniPDFDocument(data: data)
            } else if data.isImage {
                return GiniImageDocument(data: data,
                                         imageSource: documentSource,
                                         imageImportMethod: importMethod,
                                         deviceOrientation: deviceOrientation)
            }
        }
        return nil
    }
}

// MARK: GiniVisionDocument extension

extension GiniVisionDocument {
    
    fileprivate var MAX_FILE_SIZE: Int { // Bytes
        return 10 * 1024 * 1024
    }

    fileprivate var customDocumentValidations: ((GiniVisionDocument) throws -> Void)? {
        return GiniConfiguration.sharedConfiguration.customDocumentValidations
    }
    
    // MARK: File validation
    /**
     Validates a document. The validation process is done in the _global_ `DispatchQueue`.
     
     - Throws: `DocumentValidationError.exceededMaxFileSize` is thrown if the document is not valid.
     
     */
    public func validate() throws {
        let document = self
        if !maxFileSizeExceeded(forData: document.data) {
            try checkType()
            try customDocumentValidations?(self)
        } else {
            throw DocumentValidationError.exceededMaxFileSize
        }
    }
    
    // MARK: File size check
    
    fileprivate func maxFileSizeExceeded(forData data: Data) -> Bool {
        if data.count > MAX_FILE_SIZE {
            return true
        }
        return false
    }
}
