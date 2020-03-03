//
//  Event.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 03.03.20.
//

import Foundation

/**
Struct representing a tracking event. It contains the event type and an optional
dictionary for additional related data.
*/
public struct Event<T: RawRepresentable> where T.RawValue == String {
    
    public let type: T
    public let info: [String : String]?
    
    init(type: T, info: [String : String]? = nil) {
        self.type = type
        self.info = info
    }
}
