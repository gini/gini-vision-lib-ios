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
    
    static let acceptedImageTypes:[String] = [kUTTypePDF as String, kUTTypeJPEG as String, kUTTypePNG as String, kUTTypeGIF as String, kUTTypeTIFF as String]
    
    public var type: GiniDocumentType = .Image
    public var data:Data
    public var previewImage: UIImage?
    
    public init(data: Data) {
        self.data = data
        self.previewImage = UIImage(data: data)
    }
    
    public func checkType() throws {
        if self.data.isImage {
            if !(self.data.isJPEG || self.data.isPNG || self.data.isGIF || self.data.isTIFF) {
                throw PickerError.imageFormatNotValid
            }
        } else {
            throw PickerError.fileFormatNotValid
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
