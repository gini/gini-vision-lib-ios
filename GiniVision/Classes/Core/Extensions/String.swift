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
    
    static func localized<T: LocalizableStringResource>(resource: T, args: CVarArg...) -> String {
        let format = resource.localized
        
        if args.isEmpty {
            return format
        } else {
            return String(format: format, arguments: args)
        }
    }
}
