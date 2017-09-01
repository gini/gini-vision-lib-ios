//
//  GiniPDFDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/31/17.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

internal final class GiniPDFDocument:NSObject, NSItemProviderReading {
    let pdfData:Data?
    
    required init(pdfData:Data) {
        self.pdfData = pdfData        
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(pdfData: data)
    }

}
