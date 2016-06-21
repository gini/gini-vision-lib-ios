//
//  GINIVision.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

@objc public protocol GINIVisionDelegate {
    
    func didCapture(imageData: NSData)
    func didCancelCapturing()
    
    optional func didCancelAnalysis()
    
}

@objc public final class GINIVision: NSObject {
    
    public class func setConfiguration(configuration: GINIConfiguration) {
        if configuration.debugModeOn {
            print("GiniVision: Set mode to DEBUG (WARNING: Never make a release in DEBUG mode!)")
        }
        GINIConfiguration.sharedConfiguration = configuration
    }
    
    public class func viewController(withDelegate delegate: GINIVisionDelegate) -> UIViewController {
        let cameraContainerViewController = GINICameraContainerViewController()
        let navigationController = GININavigationViewController(rootViewController: cameraContainerViewController)
        navigationController.giniDelegate = delegate
        return navigationController
    }
    
    public class func viewController(withDelegate delegate: GINIVisionDelegate, withConfiguration configuration: GINIConfiguration) -> UIViewController {
        setConfiguration(configuration)
        return viewController(withDelegate: delegate)
    }
    
}