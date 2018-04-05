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

public final class GiniVisionDocumentValidator {
    
    public static var maxPagesCount: Int {
        return 10
    }
    
    fileprivate static var maxFileSize: Int { // Bytes
        return 10 * 1024 * 1024
    }
    
    // MARK: File validation
    /**
     Validates a document. The validation process is done in the _global_ `DispatchQueue`.
     Also it is possible to add custom validations in the `GiniConfiguration.customDocumentValidations`
     closure.
     
     - Throws: `DocumentValidationError.exceededMaxFileSize` is thrown if the document is not valid.
     
     */
    public class func validate(_ document: GiniVisionDocument, withConfig giniConfiguration: GiniConfiguration) throws {
        if !maxFileSizeExceeded(forData: document.data) {
            try validateType(for: document)
            let customValidationResult = giniConfiguration.customDocumentValidations(document)
            if let error = customValidationResult.error, !customValidationResult.isSuccess {
                throw error
            }
        } else {
            throw DocumentValidationError.exceededMaxFileSize
        }
    }
    
    // MARK: File size check
    
    fileprivate class func maxFileSizeExceeded(forData data: Data) -> Bool {
        if data.count > maxFileSize {
            return true
        }
        return false
    }
    
    fileprivate class func validateType(for document: GiniVisionDocument) throws {
        switch document {
        case let qrDocument as GiniQRCodeDocument:
            if qrDocument.qrCodeFormat == nil ||
                qrDocument.extractedParameters.isEmpty ||
                qrDocument.extractedParameters["iban"] == nil {
                throw DocumentValidationError.qrCodeFormatNotValid
            }
        case let pdfDocument as GiniPDFDocument:
            if pdfDocument.data.isPDF {
                if case 1...maxPagesCount = pdfDocument.numberPages {
                    return
                } else {
                    throw DocumentValidationError.pdfPageLengthExceeded
                }
            } else {
                throw DocumentValidationError.fileFormatNotValid
            }
        case let imageDocument as GiniImageDocument:
            if imageDocument.data.isImage {
                if !(imageDocument.data.isJPEG ||
                    imageDocument.data.isPNG ||
                    imageDocument.data.isGIF ||
                    imageDocument.data.isTIFF) {
                    throw DocumentValidationError.imageFormatNotValid
                }
            } else {
                throw DocumentValidationError.fileFormatNotValid
            }
        default:
            break
        }
    }
}
