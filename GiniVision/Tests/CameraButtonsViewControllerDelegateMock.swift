//
//  CameraButtonsViewControllerDelegateMock.swift
//  GiniVision-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 2/19/19.
//

import XCTest
@testable import GiniVision

final class CameraButtonViewControllerDelegateMock: CameraButtonsViewControllerDelegate {
    
    var selectedButton: CameraButtonsViewController.Button?
    
    func cameraButtons(_ viewController: CameraButtonsViewController,
                       didTapOn button: CameraButtonsViewController.Button) {
        selectedButton = button
    }
    
}
