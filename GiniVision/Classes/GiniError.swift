//
//  GiniError.swift
//  GiniVision
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

public protocol GiniVisionError:Error {}

/**
 Errors thrown on the camera screen or during camera initialization.
 */
public enum CameraError: GiniVisionError {
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
public enum ReviewError: GiniVisionError {
    
    /// Unknown error during review.
    case unknown
    
}

/**
 Errors thrown validating a document (image or pdf).
 */
public enum DocumentValidationError: GiniVisionError{
    
    /// Unknown error during review.
    case unknown
    
    /// Exceeded max file size
    case exceededMaxFileSize
    
    /// Image format not valid
    case imageFormatNotValid
    
    /// File format not valid
    case fileFormatNotValid
    
    /// Exceeded max file size
    case pdfPageLengthExceeded
    
}



