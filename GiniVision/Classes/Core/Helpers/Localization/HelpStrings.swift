//
//  HelpStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum HelpStrings: LocalizableStringResource {
    
    case menuTitle, menuFirstItemText, menuSecondItemText, menuThirdItemText, openWithTutorialTitle,
    openWithTutorialCollectionHeader, openWithTutorialStep1Title, openWithTutorialStep1Subtitle,
    openWithTutorialStep2Title, openWithTutorialStep2Subtitle,
    openWithTutorialStep3Title, openWithTutorialStep3Subtitle
    
    var tableName: String {
        return "help"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .menuTitle:
            return ("menu.title", "help menu view controller title")
        case .menuFirstItemText:
            return ("menu.firstItem", "help menu first item text")
        case .menuSecondItemText:
            return ("menu.secondItem", "help menu second item text")
        case .menuThirdItemText:
            return ("menu.thirdItem", "help menu third item text")
        case .openWithTutorialTitle:
            return ("openWithTutorial.title", "title shown when the view controller is within a view controller")
        case .openWithTutorialCollectionHeader:
            return ("openWithTutorial.collectionHeader", "intoduction header for further steps")
        case .openWithTutorialStep1Title:
            return ("openWithTutorial.step1.title", "first step title for open with tutorial")
        case .openWithTutorialStep1Subtitle:
            return ("openWithTutorial.step1.subTitle", "first step subtitle for open with tutorial")
        case .openWithTutorialStep2Title:
            return ("openWithTutorial.step2.title", "second step title for open with tutorial")
        case .openWithTutorialStep2Subtitle:
            return ("openWithTutorial.step2.subTitle", "second step subtitle for open with tutorial")
        case .openWithTutorialStep3Title:
            return ("openWithTutorial.step3.title", "third step title for open with tutorial")
        case .openWithTutorialStep3Subtitle:
            return ("openWithTutorial.step3.subTitle", "third step subtitle for open with tutorial")
        }
    }
    
    var customizable: Bool {
        switch self {
        case .menuTitle, .menuFirstItemText, .menuSecondItemText, .menuThirdItemText, .openWithTutorialTitle:
            return false
        default:
            return true
        }
    }
    
    var args: CVarArg? {
        return nil
    }
    
}
