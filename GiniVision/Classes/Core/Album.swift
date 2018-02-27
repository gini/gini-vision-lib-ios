//
//  Album.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation
import Photos

struct Album {
    var title: String
    var count: Int {
        return assets.count
    }
    var assets: [PHAsset]
}
