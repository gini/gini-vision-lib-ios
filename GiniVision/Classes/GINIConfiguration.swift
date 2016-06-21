//
//  GINIConfiguration.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

@objc public final class GINIConfiguration: NSObject {
    
    /// Singleton to make configuration internally accessible in all classes of the Gini Vision Library
    internal static var sharedConfiguration = GINIConfiguration()
    
    /// Shorthand check if debug mode is turned on
    internal static var DEBUG: Bool {
        return sharedConfiguration.debugModeOn
    }
    
    /// Can be turned on in development to unlock extra information and to save captured images to camera roll
    public var debugModeOn = false
    
    /// Sets the background in all screens of the Gini Vision Library to the specified color
    public var backgroundColor = UIColor.blackColor()
    
    /// Sets the tint color of the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color
    public var navigationBarTintColor = UINavigationBar.appearance().barTintColor ?? Colors.Gini.blue
    
    /// Sets the tint color of all navigation items in all screens of the Gini Vision Library to the globally specified color
    public var navigationBarItemTintColor = UINavigationBar.appearance().tintColor
    
    /// Sets the title color in the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color
    public var navigationBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor ?? Colors.Gini.lightBlue
    
    /// Sets the title text in the navigation bar on the camera screen
    public var navigationBarCameraTitle = NSLocalizedStringPreferred("ginivision.navigationbar.camera.title", comment: "Title in the navigation bar on the camera screen")
    
    /// Sets the title text in the navigation bar on the review screen
    public var navigationBarReviewTitle = NSLocalizedStringPreferred("ginivision.navigationbar.review.title", comment: "Title in the navigation bar on the review screen")
    
    /// Sets the close button text in the navigation bar on the camera screen; NOTE: This will be displayed instead of the close button image
    public var navigationBarCameraTitleCloseButton = NSLocalizedStringPreferred("ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen")
    
    /// Sets the help button text in the navigation bar on the camera screen; NOTE: This will be displayed instead of the help button image
    public var navigationBarCameraTitleHelpButton = NSLocalizedStringPreferred("ginivision.navigationbar.camera.help", comment: "Button title in the navigation bar for the help button on the camera screen")
    
    /// Sets the back button text in the navigation bar on the review screen; NOTE: This will be displayed instead of the back button image
    public var navigationBarReviewTitleBackButton = NSLocalizedStringPreferred("ginivision.navigationbar.review.back", comment: "Button title in the navigation bar for the back button on the review screen")
    
    /// Sets the continue button text in the navigation bar on the review screen; NOTE: This will be displayed instead of the continue button image
    public var navigationBarReviewTitleContinueButton = NSLocalizedStringPreferred("ginivision.navigationbar.review.continue", comment: "Button title in the navigation bar for the continue button on the review screen")
    
    /// Sets the text appearing at the top of the review screen which should ask the user if the full document is sharp and in the correct orientation
    public var reviewTextTop = NSLocalizedStringPreferred("ginivision.review.top", comment: "Text at the top of the review screen asking the user if the full document is sharp and in the correct orientation")
    
    /// Sets the text appearing at the bottom of the review screen which should encourage the user to check sharpness by double-tapping the image
    public var reviewTextBottom = NSLocalizedStringPreferred("ginivision.review.bottom", comment: "Text at the bottom of the review screen encouraging the user to check sharpness by double-tapping the image")
    
    public override init() {}
        
}

internal struct Colors {
    
    struct Gini {
        
        static var blue = Colors.UIColorHex(0x009edc)
        static var lightBlue = Colors.UIColorHex(0x74d1f5)
        
    }
    
    private static func UIColorHex(hex: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
