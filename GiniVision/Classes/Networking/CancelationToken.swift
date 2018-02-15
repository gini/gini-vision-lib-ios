//
//  CancelationToken.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation

/**
 Simple cancelation token implementation.
 Used in asychronous tasks.
 */
final class CancelationToken {
    
    /**
     Cancel propoerty to check the current cancelled state of the object.
     */
    var cancelled = false
    
    /**
     Sets the state of the token to cancelled.
     */
    func cancel() {
        cancelled = true
    }
    
}
