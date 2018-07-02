//
//  UINavigationController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

extension UINavigationController {
    func applyStyle(withConfiguration configuration: GiniConfiguration) {
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = configuration.navigationBarTintColor
        self.navigationBar.tintColor = configuration.navigationBarItemTintColor
        var attributes = self.navigationBar.titleTextAttributes ?? [NSAttributedStringKey: Any]()
        attributes[NSAttributedStringKey.foregroundColor] = configuration.navigationBarTitleColor
        attributes[NSAttributedStringKey.font] = configuration.customFont.isEnabled ?
            configuration.customFont.light.withSize(16) :
            configuration.navigationBarTitleFont
        self.navigationBar.titleTextAttributes = attributes
    }
}
