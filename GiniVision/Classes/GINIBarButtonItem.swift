//
//  GINIBarButtonItem.swift
//  GiniVision
//
//  Created by Peter Pult on 13/07/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GINIBarButtonItem: UIBarButtonItem {
    
    init(image: UIImage?, title: String?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector) {
        super.init()
        self.style = style
        self.target = target
        self.action = action
        
        // Prioritize image over title
        if let _ = image {
            self.image = image
        } else {
            self.title = title
        }
        
        // Set accessibility label on all elements
        self.accessibilityLabel = title
        
        var attributes = titleTextAttributes(for: UIControlState()) ?? [String : AnyObject]()
        attributes[NSFontAttributeName] = GINIConfiguration.sharedConfiguration.navigationBarItemFont
        setTitleTextAttributes(attributes, for: UIControlState())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
