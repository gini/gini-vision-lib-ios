//
//  CancelationToken.swift
//  GiniVision
//
//  Created by Peter Pult on 22/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import Foundation

/**
 Simple cancelation token implementation.
 Used in asychronous tasks.
 */
struct CancelationToken {
    
    /**
     Cancel propoerty to check the current cancelled state of the object.
     */
    var cancelled = false
    
    /**
     Sets the state of the token to cancelled.
     */
    mutating func cancel() {
        cancelled = true
    }
    
}