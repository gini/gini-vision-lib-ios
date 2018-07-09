//
//  UIDevice.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

extension UIDevice {
    var isIpad: Bool {
        return self.userInterfaceIdiom == .pad
    }
    
    var isIphone: Bool {
        return self.userInterfaceIdiom == .phone
    }
    
}
