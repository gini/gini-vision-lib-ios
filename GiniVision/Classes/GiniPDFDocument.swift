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
    
    static let acceptedPDFTypes:[String] = [kUTTypePDF as String]
    
    public var type: GiniVisionDocumentType = .PDF
    public let data:Data
    public var previewImage: UIImage?
    
    private let MAX_PDF_PAGES_COUNT = 10
    private(set) var numberPages:Int = 0
    
    /**
     Initializes a GiniPDFDocument with a preview image (from the first page)
     
     - Parameter data: PDF data
     
     */
    
    public init(data:Data) {
        self.data = data
        self.previewImage = UIImageNamedPreferred(named: "cameraDefaultDocumentImage") // Here should be the first rendered page
        if let dataProvider = CGDataProvider(data: data as CFData) {
            let pdfDocument = CGPDFDocument(dataProvider)
            self.numberPages = pdfDocument?.numberOfPages ?? 0
        }
    }
    
    /**
     Check pdf document type. It should have less than 10 pages.
     
     - Throws: `DocumentValidationError.pdfPageLengthExceeded` if page length is exceeded.
     Also throws `DocumentValidationError.fileFormatNotValid` if it is not a pdf
     
     */
    
    public func checkType() throws {
        if self.data.isPDF {
            if case 1...MAX_PDF_PAGES_COUNT = self.numberPages {
                return
            } else {
                throw DocumentValidationError.pdfPageLengthExceeded
            }
        } else {
            throw DocumentValidationError.fileFormatNotValid
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


