//
//  AnalysisResult.swift
//  GiniVision
//
//  Created by Gini GmbH on 4/2/19.
//

import Foundation
import Gini

@objc public class AnalysisResult: NSObject {
    /// Images processed in the analysis
    public let images: [UIImage]
    /// Extractions obtained after the analysis
    public let extractions: [Extraction]
    
    init(extractions: [Extraction], images: [UIImage]) {
        self.images = images
        self.extractions = extractions
    }
}
