//
//  GINIMetaInformationManager.swift
//  GiniVision
//
//  Created by Peter Pult on 27/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation

extension NSMutableDictionary {
    private var CFExifKeys: [CFString] {
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
    
    private var exifKeys: [String] {
        return CFExifKeys.map { $0 as String }
    }
    
    private var CFTiffKeys: [CFString] {
        return [
            kCGImagePropertyTIFFMake,
            kCGImagePropertyTIFFModel,
            kCGImagePropertyTIFFSoftware,
            kCGImagePropertyTIFFOrientation
        ]
    }
    
    private var tiffKeys: [String] {
        return CFTiffKeys.map { $0 as String }
    }
    
    private var CFTopLevelKeys: [CFString] {
        return [
            kCGImagePropertyExifDictionary,
            kCGImagePropertyTIFFDictionary
        ]
    }
    
    private var topLevelKeys: [String] {
        return CFTopLevelKeys.map { $0 as String }
    }
    
    private var stringKeys: [String] {
        return allKeys
                .map { $0 as? String }
                .flatMap { $0 }
    }
    
    func set(metaValue value: AnyObject?, forKey key: String) {
        // Helper method to set a value in a meta dictionary like TIFF or Exif
        func set(value: AnyObject?, forKey key: String, inMetaDictionaryWithKey metaDictionaryKey: String) {
            let metaDictionary = (self[metaDictionaryKey] as? NSMutableDictionary) ?? NSMutableDictionary()
            metaDictionary[key] = value
            self[metaDictionaryKey] = metaDictionary
        }
        
        // Assume a meta information dictionary
        if exifKeys.contains(key) {
            return set(value, forKey: key, inMetaDictionaryWithKey: kCGImagePropertyExifDictionary as String)
        }
        if tiffKeys.contains(key) {
            return set(value, forKey: key, inMetaDictionaryWithKey: kCGImagePropertyTIFFDictionary as String)
        }
        
        // If key is not known try to update an existing key
        let keys = stringKeys
        guard keys.count > 0 else { return }
        if keys.contains(key) {
            setValue(value, forKey: key)
            return
        }
        
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .flatMap { $0 }
        
        for dictionary in dictionaries {
            dictionary.set(metaValue: value, forKey: key)
        }
    }
    
    func getMetaValue(forKey key: String) -> AnyObject? {
        let keys = stringKeys
        guard keys.count > 0 else { return nil }
        if keys.contains(key) {
            return self[key]
        }
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .flatMap { $0 }
        
        for dictionary in dictionaries {
            if let value = dictionary.getMetaValue(forKey: key) {
                return value
            }
        }
        
        return nil
    }
    
    func filterDefaultValues() {
        let keys = [ exifKeys, tiffKeys, topLevelKeys].flatMap { $0 }
        filter(keys)
    }
    
    func filter(filterKeys: [String]) {
        let keys = stringKeys
        for key in keys {
            if !filterKeys.contains(key) {
                removeObjectForKey(key)
            } else if let dictionary = self[key] as? NSMutableDictionary {
                dictionary.filterDefaultValues()
            }
        }
    }
}


struct GINIMetaInformationManager {
    
    private let CFRequiredExifKeys = [
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
    
    private var requiredExifKeys: [String] {
        return CFRequiredExifKeys.map { $0 as String }
    }
    
    private let CFRequiredTiffKeys = [
        kCGImagePropertyTIFFOrientation,
        kCGImagePropertyTIFFMake,
        kCGImagePropertyTIFFModel,
        kCGImagePropertyTIFFSoftware
    ]
    
    private var requiredTiffKeys: [String] {
        return CFRequiredTiffKeys.map { $0 as String }
    }
    
    typealias MetaInformation = NSDictionary
    typealias MutableMetaInformation = NSMutableDictionary
    
    var image: UIImage?
    var metaInformation: MetaInformation?
    
    init(imageData data: NSData) {
        image = UIImage(data: data)
        metaInformation = metaInformation(fromImageData: data)
    }
    
    func filteredImageData() -> NSData? {
        guard let image = self.image else { return nil }
        var information = self.metaInformation ?? MetaInformation()
        information = addDefaultValues(toMetaInformation: information)
        guard let filteredInformation = filterDefaultValues(fromMetaInformation: information) else { return nil }
        let data = merge(image, withMetaInformation: filteredInformation)
        return data
    }
    
    private func addDefaultValues(toMetaInformation information: MetaInformation) -> MetaInformation {
        var defaultInformation = information
        defaultInformation = add(requiredValuesWithKeys: requiredExifKeys, toMetaInformation: defaultInformation)
        defaultInformation = add(requiredValuesWithKeys: requiredTiffKeys, toMetaInformation: defaultInformation)
        return defaultInformation
    }
    
    private func add(requiredValuesWithKeys keys: [String], toMetaInformation information: MetaInformation) -> MetaInformation {
        guard let addedInformation = information.mutableCopy() as? NSMutableDictionary else { return information }
        for key in keys {
            if let _ = addedInformation.getMetaValue(forKey: key) {
                continue
            }
            addedInformation.set(metaValue: value(forMetaKey: key), forKey: key)
        }
        return addedInformation
    }
    
    private func filterDefaultValues(fromMetaInformation information: MetaInformation) -> MetaInformation? {
        guard let filteredInformation = information.mutableCopy() as? NSMutableDictionary else { return nil }
        filteredInformation.filterDefaultValues()
        return filteredInformation as MetaInformation
    }
    
    private func merge(image: UIImage, withMetaInformation information: MetaInformation) -> NSData? {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return nil }
        guard let source = CGImageSourceCreateWithData(imageData, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        let mutableData = NSMutableData()
        guard let type = CGImageSourceGetType(source),
            let destination = CGImageDestinationCreateWithData(mutableData, type, count, nil) else { return nil }
        for i in 0...count - 1 {
            CGImageDestinationAddImageFromSource(destination, source, i, information as CFDictionary)
        }
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData;
    }

    private func metaInformation(fromImageData data: NSData) -> MetaInformation? {
        guard let source = CGImageSourceCreateWithData(data, nil),
            let metaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as MetaInformation? else { return nil }
        return metaData
    }
    
    private func value(forMetaKey key: String) -> AnyObject? {
        if key == kCGImagePropertyTIFFSoftware as String {
            return UIDevice.currentDevice().systemVersion
        }
        if key == kCGImagePropertyTIFFMake as String {
            return "Apple" // Hardcoded, but a pretty safe guess
        }
        if key == kCGImagePropertyTIFFModel as String {
            return deviceName()
        }
        if key == kCGImagePropertyExifUserComment as String {
            return userComment()
        }
        
        return nil
    }
    
    private func userComment() -> String {
        let platform = "iOS"
        let osVersion = UIDevice.currentDevice().systemVersion
        let giniVisionVersion = GINIVision.versionString
        return "Platform=\(platform),OSVer=\(osVersion),GiniVisionVer=\(giniVisionVersion)"
    }
    
    private func deviceName() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let code = withUnsafeMutablePointer(&systemInfo.machine) {
            ptr in String.fromCString(UnsafePointer<CChar>(ptr))
        }
        return code
    }
    
    private func getExifOrientationFromUIImageOrientation(orientation: UIImageOrientation) -> Int {
        let number: Int!
        switch orientation {
        case .Up:
            number = 1
        case .UpMirrored:
            number = 2
        case .Down:
            number = 3
        case .DownMirrored:
            number = 4
        case .Left:
            number = 8
        case .LeftMirrored:
            number = 7
        case .Right:
            number = 6
        case .RightMirrored:
            number = 5
        }
        return number
    }
    
    
}
