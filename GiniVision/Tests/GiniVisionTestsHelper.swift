//
//  GiniVisionTestsHelper.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 6/5/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
@testable import GiniVision

final class GiniVisionTestsHelper {
    
    class func fileData(named name: String, fileExtension: String) -> Data? {
        return try? Data(contentsOf: urlFromFile(named: name, fileExtension: fileExtension)!)
    }
    
    class func loadImage(named name: String, fileExtension: String = "jpg") -> UIImage? {
        return UIImage(named: name,
                       in: Bundle(for: GiniVisionTestsHelper.self),
                       compatibleWith: nil) ?? loadImageFromResources(named: name, fileExtension: fileExtension)
    }
    
    fileprivate class func loadImageFromResources(named name: String, fileExtension: String = "jpg") -> UIImage? {
        guard let path = urlFromFile(named: name, fileExtension: fileExtension)?.path else { return nil}
        
        return UIImage(contentsOfFile: path)
    }
    
    class func loadPDFDocument(named name: String) -> GiniPDFDocument {
        let data = fileData(named: name, fileExtension: "pdf")!
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniPDFDocument)!
    }
    
    class func loadImageDocument(named name: String, fileExtension: String = "jpg") -> GiniImageDocument {
        let data = fileData(named: name, fileExtension: fileExtension)!
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniImageDocument)!
    }
    
    class private func loadPage(named name: String,
                                fileExtension: String) -> GiniVisionPage {
        let data = fileData(named: name, fileExtension: fileExtension)!
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return GiniVisionPage(document: builder.build()!)
    }
    
    class func loadImagePage(named name: String, fileExtension: String = "jpg") -> GiniVisionPage {
        return self.loadPage(named: name, fileExtension: fileExtension)
    }
    
    class func loadPDFPage(named name: String) -> GiniVisionPage {
        return self.loadPage(named: name, fileExtension: "pdf")
        
    }
    
    fileprivate class func urlFromFile(named name: String, fileExtension: String) -> URL? {
        return Bundle(for: GiniVisionTestsHelper.self).url(forResource: name, withExtension: fileExtension)
    }
}
