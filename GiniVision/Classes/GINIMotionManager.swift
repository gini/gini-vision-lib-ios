//
//  GINIMotionManager.swift
//  GiniVision
//
//  Created by Peter Pult on 14/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import CoreMotion

internal class GINIMotionManager {
    
    // Static strings
    let MotionOrientationChangedNotification = "MotionOrientationChangedNotification"
    let MotionOrientationKey = "MotionOrientationKey"
    
    // Public properties
    lazy var currentOrientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
    
    // Private properties
    private var motionManager: CMMotionManager?
    private var operationQueue: NSOperationQueue?
    
    init() {
        let manager = CMMotionManager()
        guard manager.accelerometerAvailable else { return }
        operationQueue = NSOperationQueue()
        manager.accelerometerUpdateInterval = 0.2
        motionManager = manager
    }
    
    func startDetection() {
        guard let queue = operationQueue else { return print("No queue found to push accelerometer updates to") }
        motionManager?.startAccelerometerUpdatesToQueue(queue, withHandler: { (accelerometerData: CMAccelerometerData?, error: NSError?) -> Void in
            self.accelerometerDidUpdate(accelerometerData, error: error)
        })
    }
    
    func stopDetection() {
        motionManager?.stopAccelerometerUpdates()
    }
    
    private func accelerometerDidUpdate(accelerometerData: CMAccelerometerData?, error: NSError?) {
        guard error == nil else { return print("Error on accelerometer update") }
        guard let data = accelerometerData else { return }

        let orientationNew: UIDeviceOrientation
        let acceleration = data.acceleration
        
        if (acceleration.x >= 0.5) {
            orientationNew = .LandscapeRight
        } else if (acceleration.x <= -0.5) {
            orientationNew = .LandscapeLeft
        } else if (acceleration.y <= -0.35) {
            orientationNew = .Portrait
        } else if (acceleration.y >= 0.35) {
            orientationNew = .PortraitUpsideDown
        } else {
            return
        }
        
        if orientationNew == currentOrientation {
            return
        }
        
        currentOrientation = orientationNew
        
        dispatch_async(dispatch_get_main_queue(), {
            NSNotificationCenter.defaultCenter().postNotificationName(self.MotionOrientationChangedNotification, object: nil, userInfo: [self.MotionOrientationKey: self])
        })
    }
    
}