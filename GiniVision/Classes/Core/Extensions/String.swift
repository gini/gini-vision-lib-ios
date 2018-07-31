//
//  String.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

extension String {
    var splitlines: [String] {
        var lines: [String] = []
        enumerateLines(invoking: { line, _ in
            lines.append(line)
        })
        return lines
    }
    
    static func localized<T: LocalizableStringResource>(resource: T) -> String {
        return resource.localized
    }
}
