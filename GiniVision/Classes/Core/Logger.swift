//
//  Logger.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 5/14/18.
//

import Foundation
import os

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
        giniConfig.logger.log(message: "\(event) \(message)")
    }
}

@objc public protocol GiniLogger: class {
    
    /**
     Logs a message
     
     - parameter message: Message printed out
     
     */
    func log(message: String)
}

final class DefaultLogger: GiniLogger {
    
    func log(message: String) {
        let prefix = "[ GiniVision ]"

        if #available(iOS 10.0, *) {
            // When having the `OS_ACTIVITY_MODE` disabled, NSLog messages are not printed
            if ProcessInfo.processInfo.environment["OS_ACTIVITY_MODE"] == "disable" {
                print(prefix, message)
            }
            os_log("%@ %@", prefix, message)
        } else {
            NSLog("\(prefix) \(message)")
        }
    }
}
