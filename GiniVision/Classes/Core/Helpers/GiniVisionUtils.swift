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
func UIImageNamedPreferred(named name: String) -> UIImage? {
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
func NSLocalizedStringPreferredFormat(_ key: String,
                                      fallbackKey: String = "",
                                      comment: String,
                                      isCustomizable: Bool = true) -> String {
    let clientString = NSLocalizedString(key, comment: comment)
    let fallbackClientString = NSLocalizedString(fallbackKey, comment: comment)
    let format: String
    
    if (clientString.lowercased() != key.lowercased() || fallbackClientString.lowercased() != fallbackKey.lowercased())
        && isCustomizable {
        format = clientString
    } else {
        let bundle = Bundle(for: GiniVision.self)
        var defaultFormat = NSLocalizedString(key, bundle: bundle, comment: comment)
        
        if defaultFormat.lowercased() == key.lowercased() {
            defaultFormat = NSLocalizedString(fallbackKey, bundle: bundle, comment: comment)
        }
        
        format = defaultFormat
    }
    
    return format
}

struct AnimationDuration {
    static var slow = 1.0
    static var medium = 0.6
    static var fast = 0.3
}

class Constraints {
    
    enum Position {
        case top, bottom, right, left
    }
    
    class func active(item view1: Any!,
                      attr attr1: NSLayoutConstraint.Attribute,
                      relatedBy relation: NSLayoutConstraint.Relation,
                      to view2: Any?,
                      attr attr2: NSLayoutConstraint.Attribute,
                      multiplier: CGFloat = 1.0,
                      constant: CGFloat = 0,
                      priority: Float = 1000,
                      identifier: String? = nil) {
        
        let constraint = NSLayoutConstraint(item: view1!,
                                            attribute: attr1,
                                            relatedBy: relation,
                                            toItem: view2, attribute: attr2,
                                            multiplier: multiplier,
                                            constant: constant)
        active(constraint: constraint, priority: priority, identifier: identifier)
    }
    
    class func active(constraint: NSLayoutConstraint,
                      priority: Float = 1000,
                      identifier: String? = nil) {
        constraint.priority = UILayoutPriority(priority)
        constraint.identifier = identifier
        constraint.isActive = true
    }
    
    class func pin(view: UIView,
                   toSuperView superview: UIView,
                   positions: [Position] = [.top, .bottom, .left, .right]) {
        
        if positions.contains(.top) {
            Constraints.active(item: view, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        }
        
        if positions.contains(.bottom) {
            Constraints.active(item: view, attr: .bottom, relatedBy: .equal, to: superview, attr: .bottom)
        }
        
        if positions.contains(.left) {
            Constraints.active(item: view, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        }
        
        if positions.contains(.right) {
            Constraints.active(item: view, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
        }
    }
    
    class func center(view: UIView, with otherView: UIView) {
        Constraints.active(item: view, attr: .centerX, relatedBy: .equal, to: otherView, attr: .centerX)
        Constraints.active(item: view, attr: .centerY, relatedBy: .equal, to: otherView, attr: .centerY)
    }
    
}

struct Colors {
    
    struct Gini {
        
        static var blue = Colors.UIColorHex(0x009edc)
        static var bluishGreen = Colors.UIColorHex(0x007c99)
        static var crimson = Colors.UIColorHex(0xFF4F65)
        static var lightBlue = Colors.UIColorHex(0x74d1f5)
        static var grey = Colors.UIColorHex(0xAFB2B3)
        static var raspberry = Colors.UIColorHex(0xe30b5d)
        static var rose = Colors.UIColorHex(0xFC6B7E)
        
        static var pearl = Colors.UIColorHex(0xF2F2F2)
        
        @available(iOS 13.0, *)
        static var dynamicPearl = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            
            if traitCollection.userInterfaceStyle == .dark {
                return Colors.UIColorHex(0x1C1C1C)
            } else {
                return pearl
            }
        }
        
        static var paleGreen = Colors.UIColorHex(0xB8E986)
        static var springGreen = Colors.UIColorHex(0x00FA9A)
        static var veryLightGray = Colors.UIColorHex(0xD8D8D8)
        
        @available(iOS 13.0, *)
        static var dynamicVeryLightGray = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            
            if traitCollection.userInterfaceStyle == .dark {
                return Colors.UIColorHex(0x3A3A3A)
            } else {
                return Colors.UIColorHex(0xD8D8D8)
            }
        }
        
        @available(iOS 13.0, *)
        static var shadowColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            } else {
                return .black
            }
        }
    }
    
    fileprivate static func UIColorHex(_ hex: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

/**
    Set the status bar style when ViewControllerBasedStatusBarAppearance is disabled.
    If it is enabled it will not have effect.
 */

func setStatusBarStyle(to statusBarStyle: UIStatusBarStyle,
                       application: UIApplication = UIApplication.shared) {
    application.setStatusBarStyle(statusBarStyle, animated: true)
}

/**
    Measure the time spent executing a block
 */

func measure(block: () -> Void) {
    let start = Date()
    block()
    let elaspsedTime = Date().timeIntervalSince(start)
    Log(message: "Elapsed time: \(elaspsedTime) seconds", event: "⏲️")
}
