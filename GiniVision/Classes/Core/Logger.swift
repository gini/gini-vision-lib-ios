//
//  Logger.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 5/14/18.
//

import Foundation

final class Logger {
    
    enum Event {
        case error
        case success
        case warning
        
        /// Custom event with an emoji as a parameter
        case custom(String)
        
        var value: String {
            switch self {
            case .error: return "❌"
            case .success: return "✅"
            case .warning: return "⚠️"
            case .custom(let emoji): return emoji
            }
        }
    }
    
    class func log(message: String,
                   event: Event,
                   giniConfig: GiniConfiguration = .shared) {
        
        if giniConfig.debugModeOn {
            NSLog("[ GiniVision ] \(event.value) \(message)")
        }
    }
}
