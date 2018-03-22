//
//  GiniError.swift
//  GiniVision
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

public protocol GiniVisionError: Error {
    var message: String { get }
}

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
    
    public var message: String {
        // TODO: Add localized string for each case
        return ""
    }
}

/**
 Errors thrown on the review screen.
 */
@objc public enum ReviewError: Int, GiniVisionError {
    
    /// Unknown error during review.
    case unknown
    
    public var message: String {
        // TODO: Add localized string for each case
        return ""
    }
}

/**
 Errors thrown on the file picker
 */

@objc public enum FilePickerError: Int, GiniVisionError {
    
    /// Camera roll can not be loaded because the user has denied authorization in the past.
    case photoLibraryAccessDenied
    
    /// Number of files picked exceeded
    case filesPickedCountExceeded
    
    /// Mixed documents unsupported
    case mixedDocumentsUnsupported

    public var message: String {
        switch self {
        case .photoLibraryAccessDenied:
            return NSLocalizedStringPreferred("ginivision.camera.filepicker.photoLibraryAccessDenied",
                                              comment: "This message is shown when" +
                                                       "Photo library permission is denied")
        case .filesPickedCountExceeded:
            return NSLocalizedStringPreferred("ginivision.camera.documentValidationError.tooManyPages",
                                                     comment: "Message text error shown in" +
                                                        "camera screen when a pdf " +
                                                        "length is higher than 10 pages")
        case .mixedDocumentsUnsupported:
            return NSLocalizedStringPreferred("ginivision.camera.filepicker.mixedDocumentsUnsupported",
                                              comment: "Message text error when a more than one file " +
                                                "type is selected")
        }
    }
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

    public var message: String {
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
