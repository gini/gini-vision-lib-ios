//
//  PreferredResource.swift
//  Pods
//
//  Created by Nikola Sobadjiev on 16/03/2017.
//
//

import UIKit

enum ResourceSource {
    case unknown
    case library
    case custom
}

/*
 * PreferredResource typically controls what artwork (image and text) would be used in a UI element
 * such as a button or a bar button item. Resources in the Gini Vision Library are usually brandable
 * via UIAppearance, Asset catalogs and localizable strings. For instance, many buttons have a default
 * image in the library's Asset catalog, but clients are free to add an image with the same image in
 * their catalog. In this case, the customized image will be used.
 */

struct PreferredResource {
    
    let imageName:String?
    let text:String?
    let textComment:String?
    let appBundle = Bundle.main
    let libBundle = Bundle(for: GiniVision.self)
    var imageSource:ResourceSource {
        if let name = imageName {
            if UIImage(named: name, in: appBundle, compatibleWith: nil) != nil {
                return .custom
            }
            else if UIImage(named: name, in: libBundle, compatibleWith: nil) != nil {
                return .library
            }
        }
        return.unknown
    }
    
    var textSource:ResourceSource {
        if let text = text,
            let comment = textComment {
            let textFromMainBundle = NSLocalizedString(text, bundle: appBundle, comment: comment)
            if textFromMainBundle != text {
                // text was in the bundle - the resource is custom
                return .custom
            }
            let textFromLibBundle = NSLocalizedString(text, bundle: libBundle, comment: comment)
            if textFromLibBundle != text {
                return .library
            }
        }
        return .unknown
    }

    init(image:String?, title:String?, comment:String?) {
        imageName = image
        text = title
        textComment = comment
    }

    var preferredImage:UIImage? {
        if !shouldIgnoreImage && imageName != nil {
            return UIImageNamedPreferred(named: imageName!)
        }
        return nil
    }
    
    var preferredText:String? {
        if let text = text,
            let comment = textComment {
            return NSLocalizedStringPreferred(text, comment: comment)
        }
        return ""
    }
    
    // if a custom text is supplied to the control, but the image is left to the default one
    // (or not set at all), the image property needs to be ignored so that the text is shown instead
    private var shouldIgnoreImage:Bool {
        return (textSource == .custom && imageSource != .custom)
    }
}
