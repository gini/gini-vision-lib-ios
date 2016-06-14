//
//  GINICameraPreviewView.swift
//  Gini Pay 2.0
//
//  Created by Peter Pult on 14/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import AVFoundation

class GINICameraPreviewView: UIView {
    
    override class func layerClass() -> AnyClass {
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