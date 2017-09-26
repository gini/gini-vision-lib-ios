//
//  Extensions.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices

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

// MARK: Extensions
internal extension AVCaptureVideoOrientation {
    
    internal init(_ interface: UIInterfaceOrientation) {
        switch interface {
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: self = .portrait
        }
    }
    
    internal init?(_ device: UIDeviceOrientation?) {
        guard let orientation = device else { return nil }
        switch orientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
}

internal extension AVCaptureDevice {
    
    func setFlashModeSecurely(_ mode: AVCaptureFlashMode) {
        guard hasFlash && isFlashModeSupported(mode) else { return }
        guard case .some = try? lockForConfiguration() else { return print("Could not lock device for configuration") }
        flashMode = mode
        unlockForConfiguration()
    }
}

internal extension UIDevice {
    var isIpad:Bool {
        return self.userInterfaceIdiom == .pad
    }
    
    var isIphone:Bool {
        return self.userInterfaceIdiom == .phone
    }
    
}

internal extension Collection where Iterator.Element == CFString {
    
    var strings: [ String ] {
        return self.map { $0 as String }
    }
    
}

internal extension MutableCollection{
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            self.swapAt(firstUnshuffled, i)
        }
    }
}

internal extension Sequence {
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}



internal extension Data {
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]
    
    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
    
    var utiFromMimeType: Unmanaged<CFString>? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self.mimeType as CFString, nil)
    }
    
    var isPDF:Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypePDF)
        }
        return false
    }
    
    var isImage:Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeImage)
        }
        return false
    }
    
    var isPNG:Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypePNG)
        }
        return false
    }
    
    var isJPEG:Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeJPEG)
        }
        return false
    }
    
    var isGIF:Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeGIF)
        }
        return false
    }
    
    var isTIFF:Bool {
        if let uti = self.utiFromMimeType {
            return UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeTIFF)
        }
        return false
    }
    
}

internal extension UIApplication {
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else { return }
        if self.canOpenURL(settingsUrl) {
            self.openURL(settingsUrl)
        }
    }
}


