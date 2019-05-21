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
    var id: String { get }
    var previewImage: UIImage? { get }
    var isReviewable: Bool { get }
    var isImported: Bool { get }
}

// MARK: GiniVisionDocumentType

@objc public enum GiniVisionDocumentType: Int {
    case pdf = 0
    case image = 1
    case qrcode = 2
}

// MARK: GiniVisionDocumentBuilder

/**
 The `GiniVisionDocumentBuilder` provides a way to build a `GiniVisionDocument` from a `Data` object and
 a `DocumentSource`. Additionally the `DocumentImportMethod` can bet set after builder iniatilization.
 This is an example of how a `GiniVisionDocument` should be built when it has been imported
 with the _Open with_ feature.
 
 ```swift
 let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
 documentBuilder.importMethod = .openWith
 let document = documentBuilder.build()
 do {
 try document?.validate()
 ...
 } catch {
 ...
 }
 ```
 */
public class GiniVisionDocumentBuilder: NSObject {
    
    let data: Data?
    var documentSource: DocumentSource
    public var deviceOrientation: UIInterfaceOrientation?
    public var importMethod: DocumentImportMethod = .picker
    
    /**
     Initializes a `GiniVisionDocumentBuilder` with the document data and the document source.
     This method is only accesible in Swift projects.
     
     - Parameter data: data object with an unknown type
     - Parameter documentSource: document source (external, camera or appName)
     
     */
    
    public init(data: Data?, documentSource: DocumentSource) {
        self.data = data
        self.documentSource = documentSource
    }
    
    /**
     Initializes a `GiniVisionDocumentBuilder` with the document data.
     `DocumentSource` will be initialized as `DocumentSource.external`.
     This method should only be used in Objective C projects.
    */
    public convenience init(data: Data?) {
        self.init(data: data, documentSource: .external)
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
