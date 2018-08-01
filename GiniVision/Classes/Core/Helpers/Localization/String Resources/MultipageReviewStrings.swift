//
//  MultipageReviewStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum MultipageReviewStrings: LocalizableStringResource {
    
    case addButtonLabel, dragAndDropTipMessage, reorderContainerTooltipMessage, retakeActionButton, retryActionButton,
    titleMessage(page: Int, pagesCount: Int)
    
    var tableName: String {
        return "multipagereview"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .addButtonLabel:
            return ("addButtonLabel", "label shown below add button")
        case .dragAndDropTipMessage:
            return ("dragAndDropTip", "drag and drop tip shown below pages collection")
        case .reorderContainerTooltipMessage:
            return ("reorderContainerTooltipMessage", "reorder button tooltip message")
        case .retakeActionButton:
            return ("error.retakeAction", "button title for retake action")
        case .retryActionButton:
            return ("error.retryAction", "button title for retry action")
        case .titleMessage:
            return ("title", "title with the page indicator")
        }
    }
    
    var customizable: Bool {
        switch self {
        case .retakeActionButton, .retryActionButton:
            return true
        default:
            return false
        }
    }
    
    var args: CVarArg? {
        switch self {
        case .titleMessage(let page, let pagesCount):
            return [page, pagesCount]
        default:
            return nil
        }
    }
    
}