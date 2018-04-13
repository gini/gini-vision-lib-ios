//
//  GiniVisionDocumentValidator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/13/18.
//

import Foundation

final class GiniVisionDocumentValidator {
    
    static var maxPagesCount: Int {
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
    class func validate(_ document: GiniVisionDocument, withConfig giniConfiguration: GiniConfiguration) throws {
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
