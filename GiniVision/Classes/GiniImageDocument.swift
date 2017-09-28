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
    public var isReviewable: Bool
    
    fileprivate let metaInformationManager:ImageMetaInformationManager
    
    /**
     Initializes a GiniImageDocument.
     
     - Parameter data: PDF data
     - Parameter deviceOrientation: Device orientation when a picture was taken from the camera. In other cases it should be `nil`
     
     */
    
    init(data: Data, imageSource:DocumentSource, imageImportMethod:DocumentImportMethod? = nil, deviceOrientation:UIInterfaceOrientation? = nil) {
        self.previewImage = UIImage(data: data)
        self.isReviewable = true
        self.metaInformationManager = ImageMetaInformationManager(imageData: data, deviceOrientation:deviceOrientation, imageSource:imageSource, imageImportMethod:imageImportMethod)
        
        if let dataWithMetadata = metaInformationManager.imageByAddingMetadata() {
            self.data = dataWithMetadata
        } else {
            self.data = data
            assertionFailure("It wasn't possible to add metadata to the image")
        }
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
    
    func rotateImage(degrees:Int, imageOrientation:UIImageOrientation) {
        metaInformationManager.rotate(degrees: 90, imageOrientation: imageOrientation)
        guard let data = metaInformationManager.imageByAddingMetadata() else {
            assertionFailure("It wasn't possible to add metadata to the image")
            return
        }
        self.data = data
        self.previewImage = UIImage(data: data)
    }
}

// MARK: NSItemProviderReading

extension GiniImageDocument:NSItemProviderReading {
    
    static public var readableTypeIdentifiersForItemProvider: [String] {
        return acceptedImageTypes
    }
    
    static public func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data:data, imageSource: .external, imageImportMethod: .picker)
    }
    
}
