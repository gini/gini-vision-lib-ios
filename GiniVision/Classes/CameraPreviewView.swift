//
//  CameraPreviewView.swift
//  GiniVision
//
//  Created by Peter Pult on 14/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation

internal class CameraPreviewView: UIView {
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.classForCoder()
    }
    
    var session: AVCaptureSession {
        get {
            return (self.layer as! AVCaptureVideoPreviewLayer).session
        }
        set(newSession) {
            (self.layer as! AVCaptureVideoPreviewLayer).session = newSession
        }
    }
    
}
