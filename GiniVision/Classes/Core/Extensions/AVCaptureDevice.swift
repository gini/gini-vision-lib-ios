//
//  AVCaptureDevice.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice {
    
    func setFlash(mode: AVCaptureDevice.FlashMode, in settings: AVCapturePhotoSettings) {
        if hasFlash {
            switch mode {
            case .auto: settings.flashMode = .auto
            case .on: settings.flashMode = .on
            default: settings.flashMode = .off
            }
        }
    }
}
