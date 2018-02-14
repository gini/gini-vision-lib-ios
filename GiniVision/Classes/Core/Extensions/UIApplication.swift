//
//  UIApplication.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

internal extension UIApplication {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if self.canOpenURL(settingsUrl) {
            self.openURL(settingsUrl)
        }
    }
}
