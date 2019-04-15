//
//  AnalysisResult.swift
//  GiniVision
//
//  Created by Gini GmbH on 4/2/19.
//

import Foundation

@objc public class AnalysisResult: NSObject {
    /// Images processed in the analysis
    public let images: [UIImage]
    /*
     *  Extractions obtained after the analysis.
     *  Besides the list of extractions that can be found here
     *  (http://developer.gini.net/gini-api/html/document_extractions.html#available-specific-extractions),
     *  it can also return the EPSCodeUrl extraction, obtained from a EPS QR code.
     */
    public let extractions: [String: Extraction]
    
    init(extractions: [String: Extraction], images: [UIImage]) {
        self.images = images
        self.extractions = extractions
    }
}
