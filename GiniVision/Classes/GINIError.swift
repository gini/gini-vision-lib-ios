//
//  GINIError.swift
//  GiniVision
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import Foundation

@objc public enum GINICameraError: Int, ErrorType {
    
    case Unknown = 0
    case AuthorizationDenied
    case CaptureFailed
    
}

@objc public enum GINIReviewError: Int, ErrorType {
    
    case Unknown = 0
    
}