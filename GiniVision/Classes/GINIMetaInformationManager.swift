////
////  GINIMetaInformationManager.swift
////  GiniVision
////
////  Created by Peter Pult on 27/07/16.
////  Copyright © 2016 Gini. All rights reserved.
////
//
//import UIKit
//import ImageIO
//import AVFoundation
//
//
//struct GINIMetaInformationManager {
//    
//    private let CFrequiredExifKeys = [
//        kCGImagePropertyExifLensMake,
//        kCGImagePropertyExifLensModel,
//        kCGImagePropertyExifISOSpeed,
//        kCGImagePropertyExifISOSpeedRatings,
//        kCGImagePropertyExifExposureTime,
//        kCGImagePropertyExifApertureValue,
//        kCGImagePropertyExifFlash,
//        kCGImagePropertyExifCompressedBitsPerPixel,
//        kCGImagePropertyExifUserComment
//    ]
//    
//    private var requiredExifKeys: [String] {
//        return CFrequiredExifKeys.map { $0 as String }
//    }
//    
//    private let CFrequiredTIFFKeys = [
//        kCGImagePropertyTIFFMake,
//        kCGImagePropertyTIFFModel,
//        kCGImagePropertyTIFFSoftware,
//        kCGImagePropertyTIFFOrientation
//    ]
//    
//    private var requiredTIFFKeys: [String] {
//        return CFrequiredTIFFKeys.map { $0 as String }
//    }
//    
//    private let CFtopLevelKeys = [
//        kCGImagePropertyExifDictionary,
//        kCGImagePropertyTIFFDictionary
//    ]
//    
//    private var topLevelKeys: [String] {
//        return CFtopLevelKeys.map { $0 as String }
//    }
//    
//    typealias MetaInformation = NSDictionary
//    
//    var image: UIImage?
//    var metaInformation: MetaInformation?
//    
//    init(imageData data: NSData) {
//        image = UIImage(data: data)
//        metaInformation = metaInformation(fromImageData: data)
//    }
//    
//    func filteredImageData() -> NSData? {
//        guard let image = self.image else { return nil }
//        var information = self.metaInformation ?? MetaInformation()
//        information = addDefaultValues(toMetaInformation: information)
//        information = filterDefaultValues(fromMetaInformation: information)
//        let data = merge(image, withMetaInformation: information)
//        return data
//    }
//    
//    private func addDefaultValues(toMetaInformation information: MetaInformation) -> MetaInformation {
//        var defaultInformation = information
//        defaultInformation = add(requiredValuesWithKeys: requiredExifKeys, toMetaInformation: defaultInformation)
//        defaultInformation = add(requiredValuesWithKeys: requiredTIFFKeys, toMetaInformation: defaultInformation)
//        return defaultInformation
//    }
//    
//    private func add(requiredValuesWithKeys keys: [String], toMetaInformation information: MetaInformation) -> MetaInformation {
//        
//    }
//    
//    private func filterDefaultValues(fromMetaInformation information: MetaInformation) -> MetaInformation {
//        
//    }
//    
//    private func merge(image: UIImage, withMetaInformation: MetaInformation) -> NSData {
//        
//    }
//    
//    private func metaInformation(fromImageData data: NSData) -> NSDictionary? {
//        guard let source = CGImageSourceCreateWithData(data, nil),
//            let metaData = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as NSDictionary? else { return nil }
//        
//        // Filter
//        let filtered = metaData.filter { topLevelTags.map { $0 as String }.contains($0.key as! String) }
//        var filteredDictionary = [String : AnyObject]()
//        filtered.forEach { filteredDictionary[$0.key as! String] = $0.1 }
//        
//        return filteredDictionary
//    }
//    
//    func addMetaInformation(fromData data: NSData, toImage image: UIImage, withCompression compression: CGFloat) -> NSData? {
//        guard let metaData = getMetaDataFromData(data),
//              let toData = UIImageJPEGRepresentation(image, compression) else { return nil }
//        return saveMetaData(metaData, toData: toData)
//    }
//    
//    func updateOrientation(data: NSData, orientation: UIImageOrientation) -> NSData {
//        guard let metaData = getMetaDataFromData(data) else { return data }
//        
//        var dictionary = metaData[kCGImagePropertyTIFFDictionary as String] as? [String : AnyObject] ?? [String: AnyObject]()
//        let exifOrientation = getExifOrientationFromUIImageOrientation(orientation)
//        dictionary[kCGImagePropertyTIFFOrientation as String] = exifOrientation
//        let updatedMetaData = metaData.mutableCopy() as! NSMutableDictionary
//        updatedMetaData[kCGImagePropertyOrientation as String] = exifOrientation
//        updatedMetaData[kCGImagePropertyTIFFDictionary as String] = dictionary
//
//        return saveMetaData(updatedMetaData, toData: data)
//    }
//    
//    func addRequiredExifTags(imageData: NSData) -> NSData {
//        return addRequiredTags(requiredExifTags, forDictionaryWithIdentifier: kCGImagePropertyExifDictionary, toData: imageData)
//    }
//    
//    func addRequiredTIFFTags(imageData: NSData) -> NSData {
//        return addRequiredTags(requiredTIFFTags, forDictionaryWithIdentifier: kCGImagePropertyTIFFDictionary, toData: imageData)
//    }
//    
//    // MARK: Private methods
//    
//    
//    private func saveMetaData(metaData: NSDictionary, toData data: NSData) -> NSData {
//        
//        // Remove meta data from image
//        guard let image = UIImage(data: data) else { return data }
//        guard let imageData = UIImageJPEGRepresentation(image, 1) else { return data }
//        
//        
//        guard let source = CGImageSourceCreateWithData(imageData, nil) else { return data }
//        let count = CGImageSourceGetCount(source)
//        let mutableData = NSMutableData()
//        guard let type = CGImageSourceGetType(source),
//              let destination = CGImageDestinationCreateWithData(mutableData, type, count, nil) else { return data }
//        for i in 0...count - 1 {
//            CGImageDestinationAddImageFromSource(destination, source, i, metaData as CFDictionary)
//        }
//        guard CGImageDestinationFinalize(destination) else { return data }
//        return mutableData;
//    }
//    
//    private func addRequiredTags(tags: [CFString], forDictionaryWithIdentifier identifier: CFString, toData data: NSData) -> NSData {
//        guard let metaData = getMetaDataFromData(data) else { return data }
//        
//        let completeDictionary = metaData[identifier as String] as? [String : AnyObject]
//        
//        // Filter
//        let filtered = completeDictionary?.filter { tags.map { $0 as String }.contains($0.0) }
//        var filteredDictionary = [String : AnyObject]()
//        filtered?.forEach { filteredDictionary[$0.0] = $0.1 }
//        
//        let dictionary = addRequiredTagsToDictionary(tags, dictionary: filteredDictionary)
//        let updatedMetaData = metaData.mutableCopy() as! NSMutableDictionary
//        updatedMetaData[identifier as String] = dictionary
//        
//        return saveMetaData(updatedMetaData, toData: data)
//    }
//    
//    private func addRequiredTagsToDictionary(tags: [CFString], dictionary: [String: AnyObject]) -> [String: AnyObject]! {
//        var mutableDictionary = dictionary
//        let availableTags = Array(mutableDictionary.keys)
//        
//        for tag in tags {
//            if availableTags.contains(tag as String) { continue }
//            guard let valueForTag = getValueForMetaKey(tag as String) else { continue }
//            mutableDictionary[tag as String] = valueForTag
//        }
//        
//        return mutableDictionary
//    }
//    
//    private func getValueForMetaKey(key: String) -> AnyObject? {
//        if key == kCGImagePropertyTIFFSoftware as String {
//            return UIDevice.currentDevice().systemVersion
//        }
//        if key == kCGImagePropertyTIFFMake as String {
//            return "Apple" // Hardcoded, but a pretty safe guess
//        }
//        if key == kCGImagePropertyTIFFModel as String {
//            return getDeviceName()
//        }
//        if key == kCGImagePropertyExifUserComment as String {
//            return getUserComment()
//        }
//
//        return nil
//    }
//    
//    private func getUserComment() -> String {
//        let platform = "iOS"
//        let osVersion = UIDevice.currentDevice().systemVersion
//        let giniVisionVersion = GiniVisionVersionNumber
//        return "Platform=\(platform),OSVer=\(osVersion),GiniVisionVer=\(giniVisionVersion)"
//    }
//    
//    private func getDeviceName() -> String? {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let code = withUnsafeMutablePointer(&systemInfo.machine) {
//            ptr in String.fromCString(UnsafePointer<CChar>(ptr))
//        }
//        return code
//    }
//    
//    private func getExifOrientationFromUIImageOrientation(orientation: UIImageOrientation) -> Int {
//        let number: Int!
//        switch orientation {
//        case .Up:
//            number = 1
//        case .UpMirrored:
//            number = 2
//        case .Down:
//            number = 3
//        case .DownMirrored:
//            number = 4
//        case .Left:
//            number = 8
//        case .LeftMirrored:
//            number = 7
//        case .Right:
//            number = 6
//        case .RightMirrored:
//            number = 5
//        }
//        return number
//    }
//    
//}

//: Playground - noun: a place where people can play

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
        // TODO: Substitute `flatMap` with a more readable function like `removeNils` as suggested by Senseful here: http://stackoverflow.com/a/38548106/1633733
        return allKeys
                .map { $0 as? String }
                .flatMap { $0 }
    }
    
    func set(metaValue value: AnyObject?, forKey key: String) {
        let keys = stringKeys
        guard keys.count > 0 else { return }
        print("\n\n\n-------------------------------\nNEW\n-------------------------------\n")
        print("The key:  \(key)")
        print("The keys: \(keys)")
        print("The keys count: \(keys.count)")
        print("Contains? \(keys.contains(key))")
        if keys.contains(key) {
            print("setting \(key)")
            print("type \(self.dynamicType)")
            setValue(value ?? 0, forKey: key)
            return
        }
        
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .flatMap { $0 }
        
        for dictionary in dictionaries {
            dictionary.set(metaValue: value, forKey: key)
        }
        
        // TODO: Set at correct space 😱 if it couldn't be found
    }
    
    func getMetaValue(forKey key: String) -> AnyObject? {
        let keys = stringKeys
        guard keys.count > 0 else { return nil }
        if keys.contains(key) {
            print("got \(self[key]) for \(key)")
            return self[key]
        }
        let dictionaries = allValues
            .map { $0 as? NSMutableDictionary }
            .flatMap { $0 }
        
        for dictionary in dictionaries {
            return dictionary.getMetaValue(forKey: key)
        }
        
        print("return nil for \(key)")
        return nil
    }
}


struct GINIMetaInformationManager {
    
    private let CFExifKeys = [
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
    
    private var exifKeys: [String] {
        return CFExifKeys.map { $0 as String }
    }
    
    private let CFTiffKeys = [
        kCGImagePropertyTIFFOrientation,
        kCGImagePropertyTIFFMake,
        kCGImagePropertyTIFFModel,
        kCGImagePropertyTIFFSoftware
    ]
    
    private var tiffKeys: [String] {
        return CFTiffKeys.map { $0 as String }
    }
    
    private let CFTopLevelKeys = [
        kCGImagePropertyExifDictionary,
        kCGImagePropertyTIFFDictionary
    ]
    
    private var topLevelKeys: [String] {
        return CFTopLevelKeys.map { $0 as String }
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
        information = filterDefaultValues(fromMetaInformation: information)
        let data = merge(image, withMetaInformation: information)
        return data
    }
    
    private func addDefaultValues(toMetaInformation information: MetaInformation) -> MetaInformation {
        var defaultInformation = information
        defaultInformation = add(requiredValuesWithKeys: exifKeys, toMetaInformation: defaultInformation)
        defaultInformation = add(requiredValuesWithKeys: tiffKeys, toMetaInformation: defaultInformation)
        return defaultInformation
    }
    
    private func add(requiredValuesWithKeys keys: [String], toMetaInformation information: MetaInformation) -> MetaInformation {
        guard let addedInformation = information.mutableCopy() as? NSMutableDictionary else { return information }
        for key in keys {
            if let value = addedInformation.getMetaValue(forKey: key) {
                print("got \(value)")
                continue
            }
            addedInformation.set(metaValue: value(forMetaKey: key), forKey: key)
        }
        return addedInformation
    }
    
    //    private func setValue(forKey key: String) {
    //        if exifKeys.contains(key) {
    //            return
    //        }
    //        if tiffKeys.contains(key) {
    //            return
    //        }
    //        if topLevelKeys.contains(key) {
    //            return
    //        }
    //    }
    //
    //    private func addDefaultValue(forKey key: String, toMetaInformation information: MetaInformation) -> MetaInformation {
    //        guard let value = value(forMetaKey: key) else { return information }
    //        let mutableInformation = MetaInformation.mutableCopy() as! MutableMetaInformation
    //        let keys = mutableInformation
    //            .allKeys
    //            .map { $0 as! String }
    //        if keys.contains(key) {
    //            mutableInformation[key] = value
    //            return mutableInformation
    //        }
    //
    //        for topLevelKey in topLevelKeys {
    //
    //        }
    //
    //
    //
    //        for anyKey in information.allKeys {
    //            guard let key = anyKey as? String else { continue }
    //            if topLevelKeys.contains(key) {
    //                guard let subInformation = information[key] as? MetaInformation else { continue }
    //                for anySubKey in subInformation.allKeys {
    //                    guard let subKey = anySubKey as? String else { continue }
    //                    if subKey == theKey {
    //                        theValue = subInformation[subKey]
    //                        break
    //                    }
    //                }
    //            } else if key == theKey {
    //                theValue = information[key]
    //                break
    //            }
    //        }
    //        return information
    //    }
    
    private func filterDefaultValues(fromMetaInformation information: MetaInformation) -> MetaInformation {
        return information
    }
    
    private func merge(image: UIImage, withMetaInformation: MetaInformation) -> NSData {
        return UIImageJPEGRepresentation(image, 1)!
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
        let giniVisionVersion = "Playground"
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
