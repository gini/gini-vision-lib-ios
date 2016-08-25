//
//  AppDelegate.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // GiniSDK property to have global access to the Gini API.
    var giniSDK: GiniSDK?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        print("Gini Vision Library for iOS (\(GINIVision.versionString))")
        
        // Set up GiniSDK with your credentials.
        let builder = GINISDKBuilder.anonymousUserWithClientID(kGiniClientId, clientSecret: kGiniClientSecret, userEmailDomain: "example.com")
        self.giniSDK = builder.build()
        
        return true
    }
    
}