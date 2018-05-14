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
        case custom(emoji: String)
        
        var value: String {
            switch self {
            case .error: return "❌"
            case .success: return "✅"
            case .warning: return "⚠️"
            case .custom(let emoji): return emoji
            }
        }
    }
    
    class func debug(message: String,
                     event: Event,
                     giniConfig: GiniConfiguration = .shared) {
        
        if giniConfig.debugModeOn {
            print("[ GiniVision ](\(formattedString(from: Date()))): \(event.value) \(message)")
        }
    }
    
    class func formattedString(from date: Date) -> String {
        let dateFormat = "dd-MM-yy hh:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: date)
    }
}
