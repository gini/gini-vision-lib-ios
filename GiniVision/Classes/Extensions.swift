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
internal func NSLocalizedStringPreferred(_ key: String, comment: String) -> String {
    let clientString = NSLocalizedString(key, comment: comment)
    if  clientString != key {
        return clientString
    }
    let bundle = Bundle(for: GiniVision.self)
    return NSLocalizedString(key, bundle: bundle, comment: comment)
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

internal extension NSMutableDictionary {
    
    fileprivate var cfExifKeys: [CFString] {
        return [
            kCGImagePropertyExifLensMake,
            kCGImagePropertyExifLensModel,
            kCGImagePropertyExifISOSpeed,
            kCGImagePropertyExifISOSpeedRatings,
            kCGImagePropertyExifExposureTime,
            kCGImagePropertyExifApertureValue,
            kCGImagePropertyExifFlash,
            kCGImagePropertyExifCompressedBitsPerPixel,
            kCGImagePropertyExifUserComment
        ]
    }
    
    fileprivate var cfTiffKeys: [CFString] {
        return [
            kCGImagePropertyTIFFMake,
            kCGImagePropertyTIFFModel,
            kCGImagePropertyTIFFSoftware,
            kCGImagePropertyTIFFOrientation
        ]
    }
    
    fileprivate var cfTopLevelKeys: [CFString] {
        return [
            kCGImagePropertyExifDictionary,
            kCGImagePropertyTIFFDictionary
        ]
    }
    
    fileprivate var stringKeys: [String] {
        return allKeys
            .map { $0 as? String }
            .flatMap { $0 }
    }
    
    func set(metaInformation value: AnyObject?, forKey key: String, inSubdictionary isSubdictionary: Bool = false) {
        // Helper method to set a value in a meta dictionary like TIFF or Exif
        func set(_ value: AnyObject?, forKey key: String, inMetaDictionaryWithKey metaDictionaryKey: String) {
            let metaDictionary = (self[metaDictionaryKey] as? NSMutableDictionary) ?? NSMutableDictionary()
            metaDictionary[key] = value
            self[metaDictionaryKey] = metaDictionary
        }
        
        // Try to set the key in the current context
        let keys = stringKeys
        if keys.contains(key) {
            setValue(value, forKey: key)
        }
        
        // Try to set in known context
        if !isSubdictionary {
            if cfExifKeys.strings.contains(key) {
                set(value, forKey: key, inMetaDictionaryWithKey: kCGImagePropertyExifDictionary as String)
            }
            if cfTiffKeys.strings.contains(key) {
                set(value, forKey: key, inMetaDictionaryWithKey: kCGImagePropertyTIFFDictionary as String)
            }
        }
        
        // Try to set in subdictioanies
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .flatMap { $0 }
        
        for dictionary in dictionaries {
            dictionary.set(metaInformation: value, forKey: key, inSubdictionary: true)
        }
    }
    
    func getMetaInformation(forKey key: String) -> AnyObject? {
        let keys = stringKeys
        guard keys.count > 0 else { return nil }
        if keys.contains(key) {
            return self[key] as AnyObject?
        }
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .flatMap { $0 }
        
        for dictionary in dictionaries {
            if let value = dictionary.getMetaInformation(forKey: key) {
                return value
            }
        }
        
        return nil
    }
    
    func filterDefaultMetaInformation() {
        let keys = [ cfExifKeys, cfTiffKeys, cfTopLevelKeys ].flatMap { $0 }.strings
        filterMetaInformation(keys)
    }
    
    /**
     Set all values to `CFNull` if the corresponding key is not in the filtered keys array.
     
     - parameter filterKeys: The keys to filter for.
     */
    func filterMetaInformation(_ filterKeys: [String]) {
        let keys = stringKeys
        for key in keys {
            if !filterKeys.contains(key) {
                self[key] = kCFNull
            } else if let dictionary = self[key] as? NSMutableDictionary {
                dictionary.filterDefaultMetaInformation()
            }
        }
    }
}

