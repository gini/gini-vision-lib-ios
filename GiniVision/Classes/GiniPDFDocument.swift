//
//  GiniPDFDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/31/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

final class GiniPDFDocument: NSObject, GiniDocument, NSItemProviderReading {
    var type: GiniDocumentType = .PDF
    let pdfData:Data?
    private(set) var numberPages:Int = 0
    
    required init(data:Data) {
        self.pdfData = data
        if let dataProvider = CGDataProvider(data: data as CFData) {
            let pdfDocument = CGPDFDocument(dataProvider)
            self.numberPages = pdfDocument?.numberOfPages ?? 0
        }
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data)
    }

}
