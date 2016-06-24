//
//  GINIError.swift
//  GiniVision
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import Foundation

/**
 Errors thrown on the camera screen or during camera initialization.
 */
@objc public enum GINICameraError: Int, ErrorType {
    
    /// Unkown error during camera use.
    case Unknown = 0
    
    /// Camera can't not be loaded because the user has denied authorization in the past.
    case AuthorizationDenied
    
    /// Capturing could not be completed.
    case CaptureFailed
    
}

/**
 Errors thrown on the review screen.
 */
@objc public enum GINIReviewError: Int, ErrorType {
    
    /// Unkown error during review.
    case Unknown = 0
    
}