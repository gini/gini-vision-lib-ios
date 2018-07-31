//
//  Localization.swift
//  GiniVision
//
//  Created by Gini GmbH on 7/31/18.
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
