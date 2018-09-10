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
    
    class func loadFile(with name: String, fileExtension: String) -> Data? {
        let path = Bundle(for: GiniVisionTestsHelper.self).url(forResource: name, withExtension: fileExtension)
        return try? Data(contentsOf: path!)
    }
    
    class func loadImage(with name: String, fileExtension: String = "jpg") -> UIImage? {
        return UIImage(named: name,
                       in: Bundle(for: GiniVisionTestsHelper.self),
                       compatibleWith: nil) ?? loadImageFromResources(with: name, fileExtension: fileExtension)
    }
    
    fileprivate class func loadImageFromResources(with name: String, fileExtension: String = "jpg") -> UIImage? {
        guard let path = Bundle(for: GiniVisionTestsHelper.self)
            .url(forResource: name, withExtension: fileExtension)?.path else { return nil}
        
        return UIImage(contentsOfFile: path)
    }
    
    class func loadPDFDocument(withName name: String) -> GiniPDFDocument {
        let path = Bundle(for: GiniVisionTestsHelper.self).url(forResource: name, withExtension: "pdf")
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniPDFDocument)!
    }
    
    class func loadImageDocument(withName name: String, fileExtension: String = "jpg") -> GiniImageDocument {
        let path = Bundle(for: GiniVisionTestsHelper.self).url(forResource: name, withExtension: fileExtension)
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniImageDocument)!
    }
    
    class private func loadPage(withName name: String,
                                fileExtension ext: String) -> GiniVisionPage {
        let path = Bundle(for: GiniVisionTestsHelper.self).url(forResource: name, withExtension: ext)
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return GiniVisionPage(document: builder.build()!)
    }
    
    class func loadImagePage(withName name: String, fileExtension: String = "jpg") -> GiniVisionPage {
        return self.loadPage(withName: name, fileExtension: fileExtension)
    }
    
    class func loadPDFPage(withName name: String) -> GiniVisionPage {
        return self.loadPage(withName: name, fileExtension: "pdf")
        
    }
}
