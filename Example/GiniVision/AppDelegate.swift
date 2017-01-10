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
        
        // Populate setting with according values
        populateSettingsPage()
        
        // Prefer client credentials from settings before config file
        let customClientId = NSUserDefaults.standardUserDefaults().stringForKey(kSettingsGiniSDKClientIdKey) ?? ""
        let customClientSecret = NSUserDefaults.standardUserDefaults().stringForKey(kSettingsGiniSDKClientSecretKey) ?? ""
        let clientId = customClientId != "" ? customClientId : kGiniClientId
        let clientSecret = customClientSecret != "" ? customClientSecret : kGiniClientSecret
        
        // Set up GiniSDK with your credentials.
        let builder = GINISDKBuilder.anonymousUserWithClientID(clientId, clientSecret: clientSecret, userEmailDomain: "example.com")
        self.giniSDK = builder.build()
        
        print("Gini Vision Library for iOS (\(GINIVision.versionString)) / Client id: \(clientId)")

        return true
    }
    
    func populateSettingsPage() {
        NSUserDefaults.standardUserDefaults().setValue(GINIVision.versionString, forKey: kSettingsGiniVisionVersionKey)
        NSUserDefaults.standardUserDefaults().setValue(NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String, forKey: kSettingsExampleAppVersionKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
