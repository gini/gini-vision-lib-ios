//
//  AnalysisStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum AnalysisStrings: LocalizableStringResource {
    
    case analysisErrorMessage, documentCreationErrorMessage, cancelledMessage, loadingText, pdfPages,
    suggestion1Text, suggestion2Text, suggestion3Text, suggestion4Text, suggestion5Text, suggestionHeader
    
    var tableName: String {
        return "analysis"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .analysisErrorMessage:
            return ("error.analysis", "This message is shown when there is an error analyzing the document")
        case .documentCreationErrorMessage:
            return ("error.documentCreation", "This message is shown when there is an error creating the document")
        case .cancelledMessage:
            return ("error.cancelled", "This message is shown when the analysis was cancelled")
        case .loadingText:
            return ("loadingText", "Text appearing at the center of the analysis screen " +
            "indicating that the document is being analysed")
        case .pdfPages:
            return ("pdfpages",
                    "Text appearing at the top of the analysis screen indicating pdf number of pages")
        case .suggestion1Text:
            return ("suggestion.1", "First suggestion text for analysis screen")
        case .suggestion2Text:
            return ("suggestion.2", "Second suggestion text for analysis screen")
        case .suggestion3Text:
            return ("suggestion.3", "Third suggestion text for analysis screen")
        case .suggestion4Text:
            return ("suggestion.4", "Fourth suggestion text for analysis screen")
        case .suggestion5Text:
            return ("suggestion.5", "Fifth suggestion text for analysis screen")
        case .suggestionHeader:
            return ("suggestion.header", "Fourth suggestion text for analysis screen")

        }
    }
    
    var customizable: Bool {
        switch self {
        case .loadingText, .pdfPages, .cancelledMessage, .documentCreationErrorMessage:
            return true
        default:
            return false
        }
    }
    
    var args: CVarArg? {
        return nil
    }
}
