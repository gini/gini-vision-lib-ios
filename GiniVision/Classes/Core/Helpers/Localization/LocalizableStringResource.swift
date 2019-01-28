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
    var fallbackTableEntry: String { get }
    var isCustomizable: Bool { get }
}

extension LocalizableStringResource {

    var localizedFormat: String {
        let keyPrefix = "ginivision.\(tableName)"
        let key = "\(keyPrefix).\(tableEntry.value)"
        let fallbackKey = "\(keyPrefix).\(fallbackTableEntry)"

        return NSLocalizedStringPreferredFormat(key,
                                                fallbackKey: fallbackKey,
                                                comment: tableEntry.description,
                                                isCustomizable: isCustomizable)
        
    }
}
