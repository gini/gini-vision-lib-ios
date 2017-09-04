//
//  GiniImageDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 9/4/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

final public class GiniImageDocument: GiniVisionDocument {
    public var previewImage: UIImage?
    
    public var type: GiniDocumentType = .Image
    public var data:Data
    
    public init(data: Data) {
        self.data = data
        self.previewImage = UIImage(data: data)
    }
}
