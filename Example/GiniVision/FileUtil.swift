//
//  FileUtil.swift
//  GiniVision
//
//  Created by Alpár Szotyori on 21/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

class FileUtil {
    
    static func saveJpegImage(data imageData: Data, withSuffix suffix: String) {
        let documentDir = documentDirURL()
        guard let _ = documentDir else { return }
        
        let filePath = uniqueFile(withSuffix: suffix, relativeTo: documentDir!)
        guard let _ = filePath else { return }
        
        write(data: imageData, to: filePath!)
    }
    
    private static func documentDirURL() -> URL? {
        let fileManager = FileManager.default
        let documentsDir: URL?
        do {
            documentsDir = try fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        } catch let error as NSError {
            print("Error getting document dir path: \(error.description)")
            documentsDir = nil
        }
        return documentsDir
    }
    
    private static func uniqueFile(withSuffix suffix: String, relativeTo:URL) -> URL? {
        let fileName = "\(Date().timeIntervalSince1970)_\(suffix).jpeg"
        return URL(string: fileName, relativeTo: relativeTo)
    }

    private static func write(data:Data, to path: URL) {
        do {
            try data.write(to: path)
            print("Image written to \(path.absoluteString)");
        } catch let error as NSError {
            print("Error writing image: \(error.description)")
        }
    }
    
}
