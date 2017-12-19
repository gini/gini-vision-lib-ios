//
//  Coordinator.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 12/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

internal protocol Coordinator: class {
    
    var rootViewController: UIViewController  { get }
    var childCoordinators: [Coordinator] { get set }
}

internal extension Coordinator {
    
    func add(childCoordinator: Coordinator) {
        self.childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter { $0 !== childCoordinator }
    }
    
}

