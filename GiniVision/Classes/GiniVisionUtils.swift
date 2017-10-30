//
//  GiniVisionUtils.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
 
 - parameter name: The name of the image file without file extension.
 
 - returns: Image if found with name.
 */
internal func UIImageNamedPreferred(named name: String) -> UIImage? {
    if let clientImage = UIImage(named: name) {
        return clientImage
    }
    let bundle = Bundle(for: GiniVision.self)
    return UIImage(named: name, in: bundle, compatibleWith: nil)
}

/**
 Returns a localized string resource preferably from the client's bundle.
 
 - parameter key:     The key to search for in the strings file.
 - parameter comment: The corresponding comment.
 
 - returns: String resource for the given key.
 */
internal func NSLocalizedStringPreferred(_ key: String, comment: String, args: CVarArg? = nil) -> String {
    let clientString = NSLocalizedString(key, comment: comment)
    let format:String
    
    if clientString != key {
        format = clientString
    } else {
        let bundle = Bundle(for: GiniVision.self)
        format = NSLocalizedString(key, bundle: bundle, comment: comment)
    }

    if let args = args {
        return String.localizedStringWithFormat(format, args)
    } else {
        return format
    }
}

/**
 Returns a font object not dependend on the os version used. 
 Needed because `systemFontOfSize:weight:` is not available prior to iOS 8.2.
 
 - parameter weight: The weight of the font.
 - parameter size:   The size of the font.
 
 - returns: Always a font with the correct weight.
 */
internal func UIFontPreferred(_ weight: FontWeight, andSize size: CGFloat) -> UIFont {
    if #available(iOS 8.2, *) {
        return UIFont.systemFont(ofSize: size, weight: weight.cgFloatValue)
    } else {
        let fontName = weight == .regular ? "HelveticaNeue" : "HelveticaNeue-\(weight.stringValue)"
        let font = UIFont(name: fontName, size: size)
        return  font ?? UIFont.systemFont(ofSize: size)
    }
}

internal enum FontWeight {
    case thin, light, regular, bold
    
    var stringValue: String {
        switch self {
        case .thin:
            return "Thin"
        case .light:
            return "Light"
        case .regular:
            return "Regular"
        case .bold:
            return "Bold"
        }
    }
    
    @available(iOS 8.2, *)
    var cgFloatValue: CGFloat {
        switch self {
        case .thin:
            return UIFontWeightThin
        case .light:
            return UIFontWeightLight
        case .regular:
            return UIFontWeightRegular
        case .bold:
            return UIFontWeightBold
        }
    }
}

internal class ConstraintUtils {
    
    class func addActiveConstraint(item view1: AnyObject, attribute attr1: NSLayoutAttribute, relatedBy relation: NSLayoutRelation, toItem view2: AnyObject?, attribute attr2: NSLayoutAttribute, multiplier: CGFloat, constant c: CGFloat, priority: UILayoutPriority = 1000, identifier:String? = nil) {
        let constraint = NSLayoutConstraint(item: view1, attribute: attr1, relatedBy: relation, toItem: view2, attribute: attr2, multiplier: multiplier, constant: c)
        constraint.identifier = identifier
        addActiveConstraint(constraint, priority: priority)
    }
    
    class func addActiveConstraint(_ constraint: NSLayoutConstraint, priority: UILayoutPriority = 1000) {
        constraint.priority = priority
        constraint.isActive = true
    }
    
}



