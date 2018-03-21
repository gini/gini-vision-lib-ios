//
//  GiniError.swift
//  GiniVision
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

public protocol GiniVisionError: Error {}

/**
 Errors thrown on the camera screen or during camera initialization.
 */
@objc public enum CameraError: Int, GiniVisionError {
    /// Unknown error during camera use.
    case unknown
    
    /// Camera can not be loaded because the user has denied authorization in the past.
    case notAuthorizedToUseDevice
    
    /// No valid input device could be found for capturing.
    case noInputDevice
    
    /// Capturing could not be completed.
    case captureFailed
    
}

/**
 Errors thrown on the review screen.
 */
@objc public enum ReviewError: Int, GiniVisionError {
    
    /// Unknown error during review.
    case unknown
    
}

/**
 Errors thrown on the file picker
 */

@objc public enum FilePickerError: Int, GiniVisionError {
    
    /// Camera roll can not be loaded because the user has denied authorization in the past.
    case photoLibraryAccessDenied
    
    /// Number of files picked exceeded
    case filesPickedCountExceeded

}

/**
 Errors thrown validating a document (image or pdf).
 */
@objc public enum DocumentValidationError: Int, GiniVisionError, Equatable {
    
    /// Unknown error during review.
    case unknown
    
    /// Exceeded max file size
    case exceededMaxFileSize
    
    /// Image format not valid
    case imageFormatNotValid
    
    /// File format not valid
    case fileFormatNotValid
    
    /// PDF length exceeded
    case pdfPageLengthExceeded
    
    /// QR Code formar not valid
    case qrCodeFormatNotValid

    var message: String {
        switch self {
        case .exceededMaxFileSize:
            return GiniConfiguration.sharedConfiguration.documentValidationErrorExcedeedFileSize
        case .imageFormatNotValid:
            return GiniConfiguration.sharedConfiguration.documentValidationErrorWrongFormat
        case .fileFormatNotValid:
            return GiniConfiguration.sharedConfiguration.documentValidationErrorWrongFormat
        case .pdfPageLengthExceeded:
            return GiniConfiguration.sharedConfiguration.documentValidationErrorTooManyPages
        case .qrCodeFormatNotValid:
            return GiniConfiguration.sharedConfiguration.documentValidationErrorWrongFormat
        case .unknown:
            return GiniConfiguration.sharedConfiguration.documentValidationErrorGeneral
        }
    }
    
    public static func == (lhs: DocumentValidationError, rhs: DocumentValidationError) -> Bool {
        return lhs.message == rhs.message
    }
}

/**
 Errors thrown when running a custom validation.
 */
@objc public class CustomDocumentValidationError: NSError {

    public convenience init(message: String) {
        self.init(domain: "net.gini", code: 1, userInfo: ["message": message])
    }

    public var message: String {
        return userInfo["message"] as? String ?? ""
    }
}

public class CustomDocumentValidationResult: NSObject {
    private(set) var isSuccess: Bool
    private(set) var error: CustomDocumentValidationError?
    
    private init(withSuccess success: Bool, error: CustomDocumentValidationError? = nil) {
        self.isSuccess = success
        self.error = error
    }
    
    public class func success() -> CustomDocumentValidationResult {
        return CustomDocumentValidationResult(withSuccess: true)
    }
    
    public class func failure(withError error: CustomDocumentValidationError) -> CustomDocumentValidationResult {
        return CustomDocumentValidationResult(withSuccess: false, error: error)
    }
}
