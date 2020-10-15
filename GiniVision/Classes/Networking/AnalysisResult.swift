//
//  AnalysisResult.swift
//  GiniVision
//
//  Created by Gini GmbH on 4/2/19.
//

import Foundation
import Gini

@objcMembers public class AnalysisResult: NSObject {
    /// Images processed in the analysis
    public let images: [UIImage]
    /*
     *  Specific extractions obtained in the analysis.
     *  Besides the list of extractions that can be found here
     *  (http://developer.gini.net/gini-api/html/document_extractions.html#available-specific-extractions),
     *  it can also return the epsPaymentQRCodeUrl extraction, obtained from a EPS QR code.
     */
    public let extractions: [String: Extraction]
    
    /*
     *  Extraction candidates dictionary. To get the candidates for an extraction look for the
     *  `Extraction.candidates` name in the dictionary. For example the IBAN extraction's `candidates` field
     *  contains `"ibans"` and if you search for that in this dictionary, then you'll get all the IBAN candidates.
     */
    public let candidates: [String: [Extraction.Candidate]]

    /*
     *  Line item compound extractions obtained in the analysis.
     */
    public let lineItems: [[Extraction]]?
    
    public init(extractions: [String: Extraction], candidates: [String: [Extraction.Candidate]], lineItems: [[Extraction]]? = nil, images: [UIImage]) {
        self.images = images
        self.extractions = extractions
        self.candidates = candidates
        self.lineItems = lineItems
    }
}
