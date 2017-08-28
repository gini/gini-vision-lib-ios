//
//  ImageMetaInformationManager.swift
//  GiniVision
//
//  Created by Peter Pult on 27/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation
import MobileCoreServices


typealias MetaInformation = NSDictionary

/// The JPEG compression level that will be used if nothing else
/// is specified in imageData(withCompression:)
let JPEGDefaultCompression:CGFloat = 0.4

internal class ImageMetaInformationManager {
    
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
    
    // user comment fields
    let userCommentRotation = "RotDeltaDeg"
    let userCommentContentId = "ContentId"
    let userCommentPlatform = "Platform"
    let userCommentOSVer = "OSVer"
    let userCommentGiniVersionVer = "GiniVisionVer"
    let userCommentDeviceOrientation = "DeviceOrientation"
    
    var imageData: Data?
    var metaInformation: MetaInformation?
    
    // Due to future image rotations on ReviewViewController, it is necessary to preserve the device orientation
    // when the picture is taken.
    fileprivate var deviceOrientationOnCapture:String?
    
    init(imageData data: Data, deviceOrientation:UIInterfaceOrientation? = nil) {
        imageData = data
        metaInformation = metaInformation(fromImageData: data)
        
        // If the image has the DeviceOrientation, it should not be added again
        // because current device orientation could be different.
        // deviceOrientation must be always nil except when the picture has just been taken.
        deviceOrientationOnCapture = value(forUserCommentField: userCommentDeviceOrientation)
        
        guard let _ = deviceOrientationOnCapture else {
            if let deviceOrientation = deviceOrientation {
                deviceOrientationOnCapture = deviceOrientation.isLandscape ? "landscape" : "portrait"
            }
            return
        }
    }
    
    func imageData(withCompression compression: CGFloat = JPEGDefaultCompression) -> Data? {
        return generateImage(withMetaInformation: metaInformation, andCompression: compression)
    }
    
    func filterMetaInformation() {
        var information = metaInformation ?? MetaInformation()
        information = addDefaultValues(toMetaInformation: information)
        guard let filteredInformation = filterDefaultValues(fromMetaInformation: information) else { return }
        metaInformation = filteredInformation
    }
    
    func rotate(degrees:Int, imageOrientation: UIImageOrientation) {
        update(imageOrientation: imageOrientation)
        let information = metaInformation as? NSMutableDictionary
        information?.set(metaInformation: userComment(rotationDegrees: degrees) as AnyObject?, forKey: kCGImagePropertyExifUserComment as String)
    }
    
    func update(imageOrientation orientation: UIImageOrientation) {
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
    
    fileprivate func generateImage(withMetaInformation information: MetaInformation?, andCompression compression: CGFloat) -> Data? {
        guard let image = imageData else { return nil }
        guard let information = information else { return nil }
        
        let targetData = NSMutableData()
        
        let destination = CGImageDestinationCreateWithData(targetData, kUTTypeJPEG, 1, nil)!
        let source = CGImageSourceCreateWithData(image as CFData, nil)
        information.setValue(compression, forKey: kCGImageDestinationLossyCompressionQuality as String)
        
        CGImageDestinationAddImageFromSource(destination, source!, 0, information as CFDictionary)
        CGImageDestinationFinalize(destination)
        return targetData as Data
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
    
    fileprivate func userComment(rotationDegrees:Int? = nil) -> String {
        let platform = "iOS"
        let osVersion = UIDevice.current.systemVersion
        let giniVisionVersion = GiniVision.versionString
        let uuid = imageUUID()
        var comment = "\(userCommentPlatform)=\(platform),\(userCommentOSVer)=\(osVersion),\(userCommentGiniVersionVer)=\(giniVisionVersion),\(userCommentContentId)=\(uuid)"
        
        if let rotationDegrees = rotationDegrees {
            // normalize the rotation to 0-360
            let rotation = imageRotationDeltaDegrees() + rotationDegrees
            let rotationNorm = normalizedDegrees(imageRotation: rotation)
            comment += ",\(userCommentRotation)=\(rotationNorm)"
        }
        
        if let deviceOrientationOnCapture = deviceOrientationOnCapture {
            comment += ",\(userCommentDeviceOrientation)=\(deviceOrientationOnCapture)"
        }
        return comment
    }
    
    fileprivate func imageUUID() -> String {
        // if it already has one, reuse it - it shouldn't change
        // if not, generate it
        let existingUUID = uuidFromImage()
        return existingUUID ?? NSUUID().uuidString
    }
    
    fileprivate func imageRotationDeltaDegrees() -> Int {
        return rotationDeltaFromImage() ?? 0
    }
    
    fileprivate func uuidFromImage() -> String? {
        return self.value(forUserCommentField: userCommentContentId)
    }
    
    fileprivate func rotationDeltaFromImage() -> Int? {
        return Int(self.value(forUserCommentField: userCommentRotation) ?? "0")
    }
    
    fileprivate func value(forUserCommentField field:String) -> String? {
        let exifDict = metaInformation as? NSMutableDictionary
        let existingUserComment = exifDict?.getMetaInformation(forKey:kCGImagePropertyExifUserComment as String)
        let components = existingUserComment?.components(separatedBy: ",")
        let userCommentComponent = components?.filter({ (component) -> Bool in
            return component.contains(field)
        })
        let equasionComponents = userCommentComponent?.last?.components(separatedBy: "=")
        return equasionComponents?.last
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
    
    fileprivate func normalizedDegrees(imageRotation:Int) -> Int {
        var normalized = imageRotation % 360
        if imageRotation < 0 {
            normalized += 360
        }
        return normalized
    }
    
}
