//
//  Localization.swift
//  GiniVision
//
//  Created by Gini GmbH on 7/31/18.
//

import Foundation
import UIKit

typealias LocalizationEntry = (value: String, description: String)

protocol LocalizableStringResource {
    var tableName: String { get }
    var tableEntry: LocalizationEntry { get }
    var customizable: Bool { get }
    var args: CVarArg? { get }

}

extension LocalizableStringResource {
    var localized: String {
        let key = "ginivision.\(tableName).\(tableEntry.value)"
        if self.customizable {
            return NSLocalizedStringPreferred(key,
                                              comment: tableEntry.description,
                                              args: args)
        } else {
            return NSLocalizedString(key,
                                     bundle: Bundle(for: GiniVision.self),
                                     comment: tableEntry.description)
        }
    }
}
