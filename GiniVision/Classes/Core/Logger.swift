//
//  Logger.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 5/14/18.
//

import Foundation

enum LogEvent: String {
    case error = "❌"
    case success = "✅"
    case warning = "⚠️"
}

func Log(message: String,
         event: LogEvent,
         giniConfig: GiniConfiguration = .shared) {

    Log(message: message, event: event.rawValue, giniConfig: giniConfig)
}

func Log(message: String,
         event: String,
         giniConfig: GiniConfiguration = .shared) {
    
    if giniConfig.debugModeOn {
        giniConfig.logger.log(message: message, event: event)
    }
}

@objc public protocol GiniLogger: class {
    
    /**
     Logs a message
     
     - parameter message: Message printed out
     - parameter event: String which represents the printed message. i.e: ⚠️
     
     */
    func log(message: String, event: String)
}

final class DefaultLogger: GiniLogger {
    
    func log(message: String, event: String) {
        let message = "[ GiniVision ] \(event) \(message)"
        if ProcessInfo.processInfo.environment["OS_ACTIVITY_MODE"] == "disable" {
            print(message)
        }
        NSLog(message)
    }
}
