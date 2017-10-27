//
//  GiniVisionFont.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Provides a way to set all possible font weights used in the GiniVision library.
 
 **Possible weights:**
 
 * regular
 * bold
 * light
 * thin
 
 */

public struct GiniVisionFont {
    public var regular: UIFont
    public var bold: UIFont
    public var light: UIFont
    public var thin: UIFont
    
    public init(regular: UIFont, bold: UIFont, light: UIFont, thin: UIFont) {
        self.regular = regular
        self.bold = bold
        self.light = light
        self.thin = thin
    }
}
