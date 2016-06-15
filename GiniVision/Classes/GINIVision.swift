//
//  GINIVision.swift
//  Pods
//
//  Created by Gini on 15/06/16.
//
//

import Foundation

class GINIVision {
    
}

extension UIImage {
    
    /**
     * Returns an optional `UIImage` instance with the given `name` preferably from the client's bundle.
     *
     * @param name The name of the image file without file extension
     */
    class func preferredClientImage(named name: String) -> UIImage? {
        if let clientImage = UIImage(named: name) {
            return clientImage
        }
        let bundle = NSBundle(forClass: GINIVision.self)
        return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil)
    }
    
}