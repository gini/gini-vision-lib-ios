//
//  MotionManager.swift
//  GiniVision
//
//  Created by Peter Pult on 14/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import CoreMotion

internal class MotionManager {
    
    // Static strings
    let MotionOrientationChangedNotification = "MotionOrientationChangedNotification"
    let MotionOrientationKey = "MotionOrientationKey"
    
    // Public properties
    lazy var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    // Private properties
    fileprivate var motionManager: CMMotionManager?
    fileprivate var operationQueue: OperationQueue?
    
    init() {
        let manager = CMMotionManager()
        guard manager.isAccelerometerAvailable else { return }
        operationQueue = OperationQueue()
        manager.accelerometerUpdateInterval = 0.2
        motionManager = manager
    }
    
    func startDetection() {
        guard let queue = operationQueue else { return print("No queue found to push accelerometer updates to") }
        motionManager?.startAccelerometerUpdates(to: queue, withHandler: { (accelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.accelerometerDidUpdate(accelerometerData, error: error as NSError?)
        })
    }
    
    func stopDetection() {
        motionManager?.stopAccelerometerUpdates()
    }
    
    fileprivate func accelerometerDidUpdate(_ accelerometerData: CMAccelerometerData?, error: NSError?) {
        guard error == nil else { return print("Error on accelerometer update") }
        guard let data = accelerometerData else { return }

        let orientationNew: UIDeviceOrientation
        let acceleration = data.acceleration
        
        if (acceleration.x >= 0.5) {
            orientationNew = .landscapeRight
        } else if (acceleration.x <= -0.5) {
            orientationNew = .landscapeLeft
        } else if (acceleration.y <= -0.35) {
            orientationNew = .portrait
        } else if (acceleration.y >= 0.35) {
            orientationNew = .portraitUpsideDown
        } else {
            return
        }
        
        if orientationNew == currentOrientation {
            return
        }
        
        currentOrientation = orientationNew
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: self.MotionOrientationChangedNotification), object: nil, userInfo: [self.MotionOrientationKey: self])
        }
    }
    
}
