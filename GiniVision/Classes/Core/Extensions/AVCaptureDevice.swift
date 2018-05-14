//
//  AVCaptureDevice.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import AVFoundation

internal extension AVCaptureDevice {
    
    func setFlashModeSecurely(_ mode: AVCaptureDevice.FlashMode) {
        guard hasFlash && isFlashModeSupported(mode) else { return }
        guard case .some = try? lockForConfiguration() else {
            Logger.debug(message: "Could not lock device for flash configuration", event: .error)
            return
        }
        flashMode = mode
        unlockForConfiguration()
    }
}
