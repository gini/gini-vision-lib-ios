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
        super.init()

        if let dataProvider = CGDataProvider(data: data as CFData), let pdfDocument = CGPDFDocument(dataProvider) {
            self.numberPages = pdfDocument.numberOfPages
            self.previewImage = renderFirstPage(fromPdf: pdfDocument)
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
    
    fileprivate func renderFirstPage(fromPdf pdf:CGPDFDocument) -> UIImage? {
        var pdfImage:UIImage?
        let pdfDoc = pdf
        
        if let pdfPage:CGPDFPage = pdfDoc.page(at: 1) {
            var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
            pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
            
            UIGraphicsBeginImageContext(pageRect.size)
            let context:CGContext = UIGraphicsGetCurrentContext()!
            context.saveGState()
            context.translateBy(x: 0.0, y: pageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
            context.drawPDFPage(pdfPage)
            context.restoreGState()
            pdfImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return pdfImage
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


