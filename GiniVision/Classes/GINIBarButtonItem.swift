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
        
        // Prioritize title over image
        if let s = title where !s.isEmpty {
            self.title = title
        } else {
            self.image = image
        }
        
        var attributes = titleTextAttributesForState(.Normal) ?? [String : AnyObject]()
        attributes[NSFontAttributeName] = GINIConfiguration.sharedConfiguration.navigationBarItemFont
        setTitleTextAttributes(attributes, forState: .Normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}