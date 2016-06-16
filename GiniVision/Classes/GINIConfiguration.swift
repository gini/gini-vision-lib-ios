//
//  GINIConfiguration.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

public final class GINIConfiguration {
    
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
    
    /// Sets the title color in the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color
    public var navigationBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor ?? Colors.Gini.lightBlue
    
    public var navigationBarTitleCamera = NSLocalizedStringPreferred("ginivision.navigationbar.title.camera", comment: "Title in the navigation bar for the camera screen")
    
    public init() {}    
        
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
