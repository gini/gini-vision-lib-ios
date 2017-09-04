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
    private(set) var numberPages:Int = 0
    
    required init(pdfData:Data) {
        self.pdfData = pdfData
        if let dataProvider = CGDataProvider(data: pdfData as CFData) {
            let pdfDocument = CGPDFDocument(dataProvider)
            self.numberPages = pdfDocument?.numberOfPages ?? 0
        }
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(pdfData: data)
    }

}
