//
//  GiniVisionTestsHelper.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 6/5/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class GiniVisionTestsHelper {
    class func loadImage(withName name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle.main, compatibleWith: nil)
    }
    
    class func loadPDFDocument(withName name: String) -> GiniPDFDocument {
        let path = Bundle.main.url(forResource: name, withExtension: "pdf")
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniPDFDocument)!
    }
    
    class func loadImageDocument(withName name: String) -> GiniImageDocument {
        let path = Bundle.main.url(forResource: name, withExtension: "jpg")
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniImageDocument)!
    }
    
    class private func loadPage(withName name: String,
                                fileExtension ext: String) -> GiniVisionPage {
        let path = Bundle.main.url(forResource: name, withExtension: ext)
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return GiniVisionPage(document: builder.build()!)
    }
    
    class func loadImagePage(withName name: String) -> GiniVisionPage {
        return self.loadPage(withName: name, fileExtension: "jpg")
    }
    
    class func loadPDFPage(withName name: String) -> GiniVisionPage {
        return self.loadPage(withName: name, fileExtension: "pdf")
        
    }
}
