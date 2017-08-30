//
//  GININavigationViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GiniNavigationViewController: UINavigationController {
    
    var giniDelegate: GiniVisionDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        // Edit style of navigation bar
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = GiniConfiguration.sharedConfiguration.navigationBarTintColor
        navigationBar.tintColor = GiniConfiguration.sharedConfiguration.navigationBarItemTintColor
        var attributes = navigationBar.titleTextAttributes ?? [String : AnyObject]()
        attributes[NSForegroundColorAttributeName] = GiniConfiguration.sharedConfiguration.navigationBarTitleColor
        attributes[NSFontAttributeName] = GiniConfiguration.sharedConfiguration.navigationBarTitleFont
        navigationBar.titleTextAttributes = attributes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

internal extension GiniNavigationViewController {
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIDevice.current.isIpad ? .all : .portrait
    }
    
}
