//
//  GiniImageDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

final public class GiniImageDocument: NSObject, GiniVisionDocument {
    
    static let acceptedImageTypes:[String] = [kUTTypeJPEG as String, kUTTypePNG as String, kUTTypeGIF as String, kUTTypeTIFF as String]
    
    public var type: GiniVisionDocumentType = .Image
    public var data:Data
    public var previewImage: UIImage?
    
    /**
     Initializes a GiniImageDocument.
     
     - Parameter data: PDF data
     
     */
    
    public init(data: Data) {
        self.data = data
        self.previewImage = UIImage(data: data)
    }
    
    /**
     Check image document type. It should be a PNG, JPEG, GIF or TIFF.
     
     - Throws: `DocumentValidationError.imageFormatNotValid` if it is not a image valid format.
     Also throws `DocumentValidationError.fileFormatNotValid` if it is not an image
     
     */
    public func checkType() throws {
        if self.data.isImage {
            if !(self.data.isJPEG || self.data.isPNG || self.data.isGIF || self.data.isTIFF) {
                throw DocumentValidationError.imageFormatNotValid
            }
        } else {
            throw DocumentValidationError.fileFormatNotValid
        }
    }
}

// MARK: NSItemProviderReading

extension GiniImageDocument:NSItemProviderReading {
    
    static public var readableTypeIdentifiersForItemProvider: [String] {
        return acceptedImageTypes
    }
    
    static public func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data)
    }
    
}
