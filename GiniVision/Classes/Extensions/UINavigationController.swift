//
//  UINavigationController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//

import Foundation

internal extension UINavigationController {
    func applyStyle(withConfiguration configuration: GiniConfiguration){
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = configuration.navigationBarTintColor
        self.navigationBar.tintColor = configuration.navigationBarItemTintColor
        var attributes = self.navigationBar.titleTextAttributes ?? [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = configuration.navigationBarTitleColor
        attributes[NSFontAttributeName] = configuration.customFont == nil ?
            configuration.navigationBarTitleFont :
            configuration.font.light.withSize(16)
        self.navigationBar.titleTextAttributes = attributes
    }
}
