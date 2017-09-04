//
//  GiniImageDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

final class GiniImageDocument: GiniDocument {
    var type: GiniDocumentType = .Image
    var imageData:Data
    
    init(data: Data) {
        imageData = data
    }
}
