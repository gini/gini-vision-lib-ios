//
//  InputDocument.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 29.01.20.
//

import Foundation

final public class InputDocument: UIDocument {
    
    public var data: Data?
    
    enum DocumentError: Error {
        case unrecognizedContent
    }
    
    override public func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        guard let data = contents as? Data else {
            throw DocumentError.unrecognizedContent
        }
        
        self.data = data
    }
}
