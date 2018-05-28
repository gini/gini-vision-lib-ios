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
        let message = "[ GiniVision ] \(event) \(message)"
        if let loggerBlock = giniConfig.customLog {
            loggerBlock(message)
        } else {
            NSLog(message)
        }
    }
}
