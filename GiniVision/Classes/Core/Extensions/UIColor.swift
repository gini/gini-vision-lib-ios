//
//  UIColor.swift
//  GiniVision
//
//  Created by Nadya Karaban on 12.10.20.
//

import Foundation

extension UIColor {
    func colorFromGiniColor(giniColor: GiniColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return giniColor.darkModeColor
                } else {
                    /// Return the color for Light Mode
                    return giniColor.lightModeColor
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return .black
        }
    }
}
