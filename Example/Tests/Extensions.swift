//
//  Extensions.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 9/11/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import XCTest

internal extension XCTestCase {
    func loadImage(withName name:String) -> UIImage? {
        let testBundle = Bundle(for: type(of: self))
        return UIImage(named: name, in: testBundle, compatibleWith: nil)
    }
}
