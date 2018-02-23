//
//  UIViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/20/18.
//

import Foundation

extension UIViewController {
    
    enum NavBarItemPosition {
        case left, right
    }
    
    func setupNavigationItem(usingResources preferredResources: PreferredButtonResource,
                             selector: Selector,
                             position: NavBarItemPosition,
                             target: AnyObject?) {
        let buttonText = preferredResources.preferredText
        if buttonText != nil && !buttonText!.isEmpty {
            let navButton = GiniBarButtonItem(
                image: preferredResources.preferredImage,
                title: buttonText,
                style: .plain,
                target: target,
                action: selector
            )
            switch position {
            case .right:
                navigationItem.setRightBarButton(navButton, animated: false)
            case .left:
                navigationItem.setLeftBarButton(navButton, animated: false)
            }
        }
    }
}
