//
//  Extensions.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 9/20/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func isFirstViewController(inNavController navController:UINavigationController) -> Bool {
        if navController.viewControllers.count == 1 {
            return true
        }
        return false
    }
}
