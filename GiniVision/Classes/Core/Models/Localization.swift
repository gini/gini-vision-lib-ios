//
//  Localization.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation
import UIKit

typealias LocalizationEntry = (value: String, description: String)

protocol Localizable {
    var customizable: Bool { get }
    var tableEntry: LocalizationEntry { get }
    var tableName: String { get }
}

extension Localizable {
    var localized: String {
        let key = "\(tableName).\(tableEntry.value)"
        if self.customizable {
            return NSLocalizedStringPreferred(key,
                                              comment: tableEntry.description)
        } else {
            return NSLocalizedString(key,
                                     bundle: Bundle(for: GiniVision.self),
                                     comment: tableEntry.description)
        }
    }
}

enum CameraStrings: Localizable {
    
    case fileImportTip, importFileButtonLabel, qrCodeDetectedPopupMessage, qrCodeDetectedPopupButtonTitle
    
    var tableName: String { return "ginivision.camera" }
    var customizable: Bool {
        switch self {
        case .qrCodeDetectedPopupMessage, .qrCodeDetectedPopupButtonTitle:
            return true
        default:
            return false
        }
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .fileImportTip:
            return ("fileImportTip", "tooltip text indicating new file import feature")
        case .importFileButtonLabel:
            return ("fileImportButtonLabel", "label shown below import button")
        case .qrCodeDetectedPopupMessage:
            return ("qrCodeDetectedPopup.message", "Proceed button title")
        case .qrCodeDetectedPopupButtonTitle:
            return ("qrCodeDetectedPopup.buttonTitle", "Proceed button title")
            
        }
    }
}

extension String {
    static func localized<T: Localizable>(resource: T) -> String {
        return resource.localized
    }
}
