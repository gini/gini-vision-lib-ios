//
//  GINIAnalysisViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/5/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

class GINIAnalysisViewControllerTests: XCTestCase {
    
    func testPDFPagesCountLocalizedString() {
        let key = "ginivision.analysis.pdfpages"
        let localizedString = NSLocalizedStringPreferred(key, comment: "Text appearing at the top of the analysis screen indicating pdf number of pages", args: 2)

        XCTAssertNotEqual(key, localizedString)
    }

    
}
