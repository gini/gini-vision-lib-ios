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
    let format: String
    
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
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight(rawValue: weight.cgFloatValue))
    } else {
        let fontName = weight == .regular ? "HelveticaNeue" : "HelveticaNeue-\(weight.stringValue)"
        let font = UIFont(name: fontName, size: size)
        return  font ?? UIFont.systemFont(ofSize: size)
    }
}

internal struct AnimationDuration {
    static var slow = 1.0
    static var medium = 0.6
    static var fast = 0.3
}

enum Result<T> {
    case success(T)
    case failure(Error)
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
            return UIFont.Weight.thin.rawValue
        case .light:
            return UIFont.Weight.light.rawValue
        case .regular:
            return UIFont.Weight.regular.rawValue
        case .bold:
            return UIFont.Weight.bold.rawValue
        }
    }
}

internal class Constraints {
    
    class func active(item view1: Any,
                      attr attr1: NSLayoutAttribute,
                      relatedBy relation: NSLayoutRelation,
                      to view2: Any?,
                      attr attr2: NSLayoutAttribute,
                      multiplier: CGFloat = 1.0,
                      constant: CGFloat = 0,
                      priority: Float = 1000,
                      identifier: String? = nil) {
        
        let constraint = NSLayoutConstraint(item: view1,
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
    
    class func pin(view: UIView, toSuperView superview: UIView) {
        Constraints.active(item: view, attr: .top, relatedBy: .equal, to: superview, attr: .top)
        Constraints.active(item: view, attr: .bottom, relatedBy: .equal, to: superview, attr: .bottom)
        Constraints.active(item: view, attr: .leading, relatedBy: .equal, to: superview, attr: .leading)
        Constraints.active(item: view, attr: .trailing, relatedBy: .equal, to: superview, attr: .trailing)
    }
    
    class func center(view: UIView, with otherView: UIView) {
        Constraints.active(item: view, attr: .centerX, relatedBy: .equal, to: otherView, attr: .centerX)
        Constraints.active(item: view, attr: .centerY, relatedBy: .equal, to: otherView, attr: .centerY)
    }
    
}

internal struct Colors {
    
    struct Gini {
        
        static var blue = Colors.UIColorHex(0x009edc)
        static var bluishGreen = Colors.UIColorHex(0x007c99)
        static var crimson = Colors.UIColorHex(0xFF4F65)
        static var lightBlue = Colors.UIColorHex(0x74d1f5)
        static var grey = Colors.UIColorHex(0xAFB2B3)
        static var raspberry = Colors.UIColorHex(0xe30b5d)
        static var rose = Colors.UIColorHex(0xFC6B7E)
        static var pearl = Colors.UIColorHex(0xF2F2F2)
        static var paleGreen = Colors.UIColorHex(0xB8E986)
        static var springGreen = Colors.UIColorHex(0x00FA9A)
        static var veryLightGray = Colors.UIColorHex(0xD8D8D8)
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

internal func setStatusBarStyle(to statusBarStyle: UIStatusBarStyle,
                                application: UIApplication = UIApplication.shared) {
    application.setStatusBarStyle(statusBarStyle, animated: true)
}

/**
    Measure the time spent executing a block
 */

internal func measure(block: () -> Void) {
    let start = Date()
    block()
    let elaspsedTime = Date().timeIntervalSince(start)
    Logger.debug(message: "Elapsed time: \(elaspsedTime) seconds", event: .custom(emoji: "⏲️"))
}
