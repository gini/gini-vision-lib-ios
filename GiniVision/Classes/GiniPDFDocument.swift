//
//  GiniPDFDocument.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/31/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import MobileCoreServices

final public class GiniPDFDocument: NSObject, GiniVisionDocument {
    
    public var type: GiniDocumentType = .PDF
    public let data:Data
    public var previewImage: UIImage?
    
    private(set) var numberPages:Int = 0
    
    public init(data:Data) {
        self.data = data
        self.previewImage = UIImageNamedPreferred(named: "cameraDefaultDocumentImage") // Here should be the first rendered page
        if let dataProvider = CGDataProvider(data: data as CFData) {
            let pdfDocument = CGPDFDocument(dataProvider)
            self.numberPages = pdfDocument?.numberOfPages ?? 0
        }
    }
    
    public func checkType() throws {
        if self.data.isPDF {
            if case 1...10 = self.numberPages {
                return
            } else {
                throw PickerError.pdfPageLengthExceeded
            }
        } else {
            throw PickerError.fileFormatNotValid
        }
    }
    
}

// MARK: NSItemProviderReading

extension GiniPDFDocument:NSItemProviderReading {
    
    static public var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypePDF as String]
    }
    
    static public func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init(data: data)
    }
    
}


