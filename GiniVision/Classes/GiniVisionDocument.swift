//
//  GiniVisionDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

@objc public protocol GiniVisionDocument:class {
    var type:GiniDocumentType { get }
    var data:Data { get }
    var previewImage:UIImage? { get }
    
    init(data:Data)
    func checkType() throws
}

// MARK: GiniDocumentType

@objc public enum GiniDocumentType:Int {
    case PDF = 0
    case Image = 1
}

// MARK: GiniVisionDocument extension

extension GiniVisionDocument {
    
    fileprivate var MAX_FILE_SIZE:Double {
        return 10.0
    }
    
    // MARK: File validation
    
    func validate() throws {
        let document = self
        if !maxFileSizeExceeded(forData: document.data) {
            try checkType()
        } else {
            throw PickerError.exceededMaxFileSize
        }
    }

    // MARK: File size check
    
    fileprivate func maxFileSizeExceeded(forData data:Data) -> Bool {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        bcf.includesUnit = false
        
        if let fileSize = NumberFormatter().number(from: bcf.string(fromByteCount: Int64(data.count)))?.doubleValue {
            return fileSize > MAX_FILE_SIZE
        }
        
        return false
    }
    
    // MARK: File type check
    
    fileprivate func isValidImage(imageData:Data) throws {
        if imageData.isImage {
            if !(imageData.isJPEG || imageData.isPNG || imageData.isGIF || imageData.isTIFF) {
                throw PickerError.imageFormatNotValid
            }
        } else {
            throw PickerError.fileFormatNotValid
        }

    }
    
    fileprivate func isValidPDF(pdfDocument:GiniPDFDocument) throws {
        if pdfDocument.data.isPDF {
            if case 1...10 = pdfDocument.numberPages {
                return
            } else {
                throw PickerError.pdfPageLengthExceeded
            }
        } else {
            throw PickerError.fileFormatNotValid
        }
    }
}


