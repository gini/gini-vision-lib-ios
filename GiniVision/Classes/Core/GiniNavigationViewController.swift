//
//  GININavigationViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GiniNavigationViewController: UINavigationController {
    
    weak var giniDelegate: GiniVisionDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        // Edit style of navigation bar
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = GiniConfiguration.shared.navigationBarTintColor
        navigationBar.tintColor = GiniConfiguration.shared.navigationBarItemTintColor
        var attributes = navigationBar.titleTextAttributes ?? [NSAttributedStringKey: Any]()
        attributes[NSAttributedStringKey.foregroundColor] = GiniConfiguration.shared.navigationBarTitleColor
        attributes[NSAttributedStringKey.font] = GiniConfiguration.shared.customFont.isEnabled ?
            GiniConfiguration.shared.customFont.light.withSize(16) :
            GiniConfiguration.shared.navigationBarTitleFont
        navigationBar.titleTextAttributes = attributes
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}

internal extension GiniNavigationViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isIpad ? .all : .portrait
    }
    
}
