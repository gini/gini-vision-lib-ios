//
//  ImageAnalysisNoResultsStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

public enum ImageAnalysisNoResultsStrings: LocalizableStringResource {
    
    case collectionHeaderText, goToCameraButton, titleText, warningText, warningHelpMenuText
    
    var tableName: String {
        return "noresults"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .collectionHeaderText:
            return ("collection.header", "no results suggestions collection header title")
        case .goToCameraButton:
            return ("gotocamera", "bottom button title (go to camera button)")
        case .titleText:
            return ("title",
                    "navigation title shown on no results tips, when the screen is shown through the help menu")
        case .warningText:
            return ("warning", "Warning text that indicates that there was any result for this photo analysis")
        case .warningHelpMenuText:
            return ("warningHelpMenu",
                    "warning text shown on no results tips, when the screen is shown through the help menu")
        }
    }
    
    var customizable: Bool {
        switch self {
        case .collectionHeaderText, .goToCameraButton, .titleText, .warningText, .warningHelpMenuText:
            return false
        }
    }
    
}
