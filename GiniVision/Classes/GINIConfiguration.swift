//
//  GINIConfiguration.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

/**
 The `GINIConfiguration` class allows customizations to the look and feel of the Gini Vision Library. If there are limitations regarding which API can be used it is clearly stated on the specific attribute.
 
 - note: Texts can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle. The library will prefer what ever value is set in the following order: attribute in configuration, key in strings file in project bundle, key in strings file in `GiniVision` bundle.
 - note: Images can be set by providing images with the same filename in an assets file or as individual files in the projects bundle. The library will prefer what ever value is set in the following order: asset file in project bundle, asset file in `GiniVision` bundle.
 */
@objc public final class GINIConfiguration: NSObject {
    
    /// Singleton to make configuration internally accessible in all classes of the Gini Vision Library
    internal static var sharedConfiguration = GINIConfiguration()
    
    /// Shorthand check if debug mode is turned on
    internal static var DEBUG: Bool {
        return sharedConfiguration.debugModeOn
    }
    
    /// Can be turned on in development to unlock extra information and to save captured images to camera roll.
    /// - warning: Should never be used outside of a development enviroment.
    public var debugModeOn = false
    
    /// Sets the background in all screens of the Gini Vision Library to the specified color.
    /// - note: Screen API only.
    public var backgroundColor = UIColor.blackColor()
    
    /// Sets the tint color of the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color.
    /// - note: Screen API only.
    public var navigationBarTintColor = UINavigationBar.appearance().barTintColor ?? Colors.Gini.blue
    
    /// Sets the tint color of all navigation items in all screens of the Gini Vision Library to the globally specified color.
    /// - note: Screen API only.
    public var navigationBarItemTintColor = UINavigationBar.appearance().tintColor
    
    /// Sets the title color in the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color.
    /// - note: Screen API only.
    public var navigationBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor ?? Colors.Gini.lightBlue
    
    /// Sets the color of the loading indicator on the analysis screen to the specified color.
    public var analysisLoadingIndicatorColor = UIColor.whiteColor()
    
    /// Sets the title text in the navigation bar on the camera screen.
    /// - note: Screen API only.
    public var navigationBarCameraTitle = NSLocalizedStringPreferred("ginivision.navigationbar.camera.title", comment: "Title in the navigation bar on the camera screen")
    
    /// Sets the title text in the navigation bar on the review screen.
    /// - note: Screen API only.
    public var navigationBarReviewTitle = NSLocalizedStringPreferred("ginivision.navigationbar.review.title", comment: "Title in the navigation bar on the review screen")
    
    /// Sets the title text in the navigation bar on the analysis screen.
    /// - note: Screen API only.
    public var navigationBarAnalysisTitle = NSLocalizedStringPreferred("ginivision.navigationbar.analysis.title", comment: "Title in the navigation bar on the analysis screen")
    
    /// Sets the close button text in the navigation bar on the camera screen.
    /// - attention: This will be displayed instead of the close button image.
    /// - note: Screen API only.
    public var navigationBarCameraTitleCloseButton = NSLocalizedStringPreferred("ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen")
    
    /// Sets the help button text in the navigation bar on the camera screen.
    /// - attention: This will be displayed instead of the help button image.
    /// - note: Screen API only.
    public var navigationBarCameraTitleHelpButton = NSLocalizedStringPreferred("ginivision.navigationbar.camera.help", comment: "Button title in the navigation bar for the help button on the camera screen")
    
    /// Sets the back button text in the navigation bar on the review screen.
    /// - attention: This will be displayed instead of the back button image.
    /// - note: Screen API only.
    public var navigationBarReviewTitleBackButton = NSLocalizedStringPreferred("ginivision.navigationbar.review.back", comment: "Button title in the navigation bar for the back button on the review screen")
    
    /// Sets the continue button text in the navigation bar on the review screen.
    /// - attention: This will be displayed instead of the continue button image.
    /// - note: Screen API only.
    public var navigationBarReviewTitleContinueButton = NSLocalizedStringPreferred("ginivision.navigationbar.review.continue", comment: "Button title in the navigation bar for the continue button on the review screen")
    
    /// Sets the text appearing at the top of the review screen which should ask the user if the full document is sharp and in the correct orientation
    public var reviewTextTop = NSLocalizedStringPreferred("ginivision.review.top", comment: "Text at the top of the review screen asking the user if the full document is sharp and in the correct orientation")
    
    /// Sets the text appearing at the bottom of the review screen which should encourage the user to check sharpness by double-tapping the image
    public var reviewTextBottom = NSLocalizedStringPreferred("ginivision.review.bottom", comment: "Text at the bottom of the review screen encouraging the user to check sharpness by double-tapping the image")
    
    /// Sets the back button text in the navigation bar on the analysis screen; NOTE: This will be displayed instead of the back button image
    public var navigationBarAnalysisTitleBackButton = NSLocalizedStringPreferred("ginivision.navigationbar.analysis.back", comment: "Button title in the navigation bar for the back button on the analysis screen")
    
    /**
     Returns a `GiniConfiguration` instance which allows to set individual configurations to change the look and feel of the Gini Vision Library.
     
     - returns: Instance of `GiniConfiguration`.
     */
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
