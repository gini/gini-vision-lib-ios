//
//  GiniBarButtonItem.swift
//  GiniVision
//
//  Created by Peter Pult on 13/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

final class GiniBarButtonItem: UIBarButtonItem {
    
    init(image: UIImage?, title: String?, style: UIBarButtonItem.Style, target: AnyObject?, action: Selector) {
        super.init()
        self.style = style
        self.target = target
        self.action = action
        
        // Prioritize image over title
        if image != nil {
            self.image = image
        } else {
            self.title = title
        }
        
        // Set accessibility label on all elements
        self.accessibilityLabel = title
        
        let font = GiniConfiguration.shared.navigationBarItemFont
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        setTitleTextAttributes(attributes, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
