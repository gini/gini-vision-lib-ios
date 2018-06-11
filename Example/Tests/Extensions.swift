//
//  Extensions.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 9/11/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import XCTest
@testable import GiniVision

internal extension XCTestCase {
    func loadImage(withName name: String) -> UIImage? {
        let testBundle = Bundle(for: type(of: self))
        return UIImage(named: name, in: testBundle, compatibleWith: nil)
    }
    
    func loadPDFDocument(withName name: String) -> GiniPDFDocument {
        let path = Bundle.main.url(forResource: name, withExtension: "pdf")
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniPDFDocument)!
    }
    
    func loadImageDocument(withName name: String) -> GiniImageDocument {
        let path = Bundle.main.url(forResource: name, withExtension: "jpg")
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return (builder.build() as? GiniImageDocument)!
    }
    
    private func loadPage(withName name: String,
                                     fileExtension ext: String) -> GiniVisionPage {
        let path = Bundle.main.url(forResource: name, withExtension: ext)
        let data = try? Data(contentsOf: path!)
        let builder = GiniVisionDocumentBuilder(data: data, documentSource: .external)
        return GiniVisionPage(document: builder.build()!)
    }
    
    func loadImagePage(withName name: String) -> GiniVisionPage {
        return self.loadPage(withName: name, fileExtension: "jpg")
    }
    
    func loadPDFPage(withName name: String) -> GiniVisionPage {
        return self.loadPage(withName: name, fileExtension: "pdf")

    }
}
