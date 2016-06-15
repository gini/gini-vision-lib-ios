//
//  GINIVision.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

public final class GINIVision {
    
    public class func setConfiguration(configuration: GINIConfiguration) {
        if configuration.debugModeOn {
            print("GiniVision: Set mode to DEBUG (WARNING: Never make a release in DEBUG mode!)")
        }
        GINIConfiguration.sharedConfiguration = configuration
    }
    
    public class func viewController() -> UIViewController {
        let cameraContainerViewController = GINICameraContainerViewController()
        let navigationController = GININavigationViewController(rootViewController: cameraContainerViewController)
        return navigationController
    }
    
    public class func viewController(withConfiguration configuration: GINIConfiguration) -> UIViewController {
        setConfiguration(configuration)
        return viewController()
    }
    
}