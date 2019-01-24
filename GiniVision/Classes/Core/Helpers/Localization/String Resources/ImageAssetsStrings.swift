//
//  ImageAssetsStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/23/19.
//

import Foundation

public enum ImageAssetsStrings: LocalizableStringResource {
    
    case openWithTutorialStep1, openWithTutorialStep2, openWithTutorialStep3
    
    var tableName: String {
        return "images"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .openWithTutorialStep1:
            return ("openWithTutorialStep1", "Firs step image name")
        case .openWithTutorialStep2:
            return ("openWithTutorialStep2", "Second step image name")
        case .openWithTutorialStep3:
            return ("openWithTutorialStep3", "Third step image name")
        }
    }
    
    var isCustomizable: Bool {
        return true
    }
    
    var fallbackTableEntry: String {
        return ""
    }
}
