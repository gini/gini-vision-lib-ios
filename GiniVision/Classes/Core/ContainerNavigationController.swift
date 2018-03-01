//
//  ContainerNavigationController.swift
//  GiniVisionExample
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini. All rights reserved.
//

import UIKit

final class ContainerNavigationController: UIViewController {
    
    var rootViewController: UINavigationController
    var coordinator: Coordinator?
    var giniConfiguration: GiniConfiguration
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIDevice.current.isIpad ? .all : .portrait
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniConfiguration.statusBarStyle
    }
    
    /**
     Container that wraps a UINavigationController in order to handle rotation.
     Parent coordinator should be always `nil` excepts when there is no possibility
     to keep a strong reference inside of the Gini Vision Library.
     */
    init(rootViewController: UINavigationController,
         parent: Coordinator? = nil,
         giniConfiguration: GiniConfiguration = GiniConfiguration.sharedConfiguration) {
        self.rootViewController = rootViewController
        self.coordinator = parent
        self.giniConfiguration = giniConfiguration
        setStatusBarStyle(to: giniConfiguration.statusBarStyle)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(rootViewController:parent:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addChildViewController(rootViewController)
        view.addSubview(rootViewController.view)
        rootViewController.willMove(toParentViewController: self)
        rootViewController.didMove(toParentViewController: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootViewController.view.frame = self.view.bounds
    }
}

