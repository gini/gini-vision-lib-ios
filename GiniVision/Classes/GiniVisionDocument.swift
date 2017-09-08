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
    
    fileprivate var MAX_FILE_SIZE:Int { // Bytes
        return 10 * 1024 * 1024
    }
    
    // MARK: File validation
    
    func validate() throws {
        let document = self
        if !maxFileSizeExceeded(forData: document.data) {
            try checkType()
        } else {
            throw DocumentValidationError.exceededMaxFileSize
        }
    }

    // MARK: File size check
    
    fileprivate func maxFileSizeExceeded(forData data:Data) -> Bool {
        if data.count > MAX_FILE_SIZE {
            return true
        }
        return false
    }
}


