//
//  Bundle.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//

import Foundation

extension Bundle {
    var appName: String {
        return self.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
    }
}
