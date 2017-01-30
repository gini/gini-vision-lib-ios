//
//  GiniMetaInformationManager.swift
//  GiniVision
//
//  Created by Peter Pult on 27/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation

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

typealias MetaInformation = NSDictionary

/// The JPEG compression level that will be used if nothing else
/// is specified in imageData(withCompression:)
let JPEGDefaultCompression:CGFloat = 0.2

internal struct GiniMetaInformationManager {
    
    fileprivate let cfRequiredExifKeys = [
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
    
    fileprivate let cfRequiredTiffKeys = [
        kCGImagePropertyTIFFOrientation,
        kCGImagePropertyTIFFMake,
        kCGImagePropertyTIFFModel,
        kCGImagePropertyTIFFSoftware
    ]
    
    var image: UIImage?
    var metaInformation: MetaInformation?
    
    init(imageData data: Data) {
        image = UIImage(data: data)
        metaInformation = metaInformation(fromImageData: data)
    }
    
    func imageData(withCompression compression: CGFloat = JPEGDefaultCompression) -> Data? {
        return merge(image, withMetaInformation: metaInformation, andCompression: compression)
    }
    
    mutating func filterMetaInformation() {
        var information = metaInformation ?? MetaInformation()
        information = addDefaultValues(toMetaInformation: information)
        guard let filteredInformation = filterDefaultValues(fromMetaInformation: information) else { return }
        metaInformation = filteredInformation
    }
    
    mutating func update(imageOrientation orientation: UIImageOrientation) {
        var information = metaInformation ?? MetaInformation()
        information = update(getExifOrientationFromUIImageOrientation(orientation), onMetaInformation: information)
        metaInformation = information
    }
    
    fileprivate func update(_ orientation: Int, onMetaInformation information: MetaInformation) -> MetaInformation {
        guard let updatedInformation = information.mutableCopy() as? NSMutableDictionary else { return information }
        // Set both keys in case one is changed in the future all orientations will still be set correctly
        updatedInformation.set(metaInformation: orientation as AnyObject?, forKey: kCGImagePropertyTIFFOrientation as String)
        updatedInformation.set(metaInformation: orientation as AnyObject?, forKey: kCGImagePropertyOrientation as String)
        return updatedInformation
    }
    
    fileprivate func addDefaultValues(toMetaInformation information: MetaInformation) -> MetaInformation {
        var defaultInformation = information
        defaultInformation = add(requiredValuesWithKeys: cfRequiredExifKeys.strings, toMetaInformation: defaultInformation)
        defaultInformation = add(requiredValuesWithKeys: cfRequiredTiffKeys.strings, toMetaInformation: defaultInformation)
        return defaultInformation
    }
    
    fileprivate func add(requiredValuesWithKeys keys: [String], toMetaInformation information: MetaInformation) -> MetaInformation {
        guard let addedInformation = information.mutableCopy() as? NSMutableDictionary else { return information }
        for key in keys {
            if let _ = addedInformation.getMetaInformation(forKey: key) {
                continue
            }
            addedInformation.set(metaInformation: value(forMetaKey: key), forKey: key)
        }
        return addedInformation
    }
    
    fileprivate func filterDefaultValues(fromMetaInformation information: MetaInformation) -> MetaInformation? {
        guard let filteredInformation = information.mutableCopy() as? NSMutableDictionary else { return nil }
        filteredInformation.filterDefaultMetaInformation()
        return filteredInformation as MetaInformation
    }
    
    fileprivate func merge(_ image: UIImage?, withMetaInformation information: MetaInformation?, andCompression compression: CGFloat) -> Data? {
        guard let image = image else { return nil }
        guard let information = information else { return nil }
        guard let imageData = UIImageJPEGRepresentation(image, compression) else { return nil }
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        let mutableData = NSMutableData(data: imageData)
        guard let type = CGImageSourceGetType(source),
              let destination = CGImageDestinationCreateWithData(mutableData, type, count, nil) else { return nil }
        for i in 0...count - 1 {
            CGImageDestinationAddImageFromSource(destination, source, i, information as CFDictionary)
        }
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data;
    }

    fileprivate func metaInformation(fromImageData data: Data) -> MetaInformation? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let metaInformation = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as MetaInformation? else { return nil }
        return metaInformation
    }
    
    fileprivate func value(forMetaKey key: String) -> AnyObject? {
        if key == kCGImagePropertyTIFFSoftware as String {
            return UIDevice.current.systemVersion as AnyObject?
        }
        if key == kCGImagePropertyTIFFMake as String {
            return "Apple" as AnyObject? // Hardcoded, but a pretty safe guess
        }
        if key == kCGImagePropertyTIFFModel as String {
            return deviceName() as AnyObject?
        }
        if key == kCGImagePropertyExifUserComment as String {
            return userComment() as AnyObject?
        }
        
        return nil
    }
    
    fileprivate func userComment() -> String {
        let platform = "iOS"
        let osVersion = UIDevice.current.systemVersion
        let giniVisionVersion = GiniVision.versionString
        return "Platform=\(platform),OSVer=\(osVersion),GiniVisionVer=\(giniVisionVersion)"
    }
    
    fileprivate func deviceName() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let code = withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        return code
    }
    
    fileprivate func getExifOrientationFromUIImageOrientation(_ orientation: UIImageOrientation) -> Int {
        let number: Int
        switch orientation {
        case .up:
            number = 1
        case .upMirrored:
            number = 2
        case .down:
            number = 3
        case .downMirrored:
            number = 4
        case .left:
            number = 8
        case .leftMirrored:
            number = 7
        case .right:
            number = 6
        case .rightMirrored:
            number = 5
        }
        return number
    }
    
}
