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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Populate setting with according values
        populateSettingsPage()
        
        // Prefer client credentials from settings before config file
        let customClientId = UserDefaults.standard.string(forKey: kSettingsGiniSDKClientIdKey) ?? ""
        let customClientSecret = UserDefaults.standard.string(forKey: kSettingsGiniSDKClientSecretKey) ?? ""
        let clientId = customClientId != "" ? customClientId : kGiniClientId
        let clientSecret = customClientSecret != "" ? customClientSecret : kGiniClientSecret
        
        // Set up GiniSDK with your credentials.
        let builder = GINISDKBuilder.anonymousUser(withClientID: clientId, clientSecret: clientSecret, userEmailDomain: "example.com")
        self.giniSDK = builder?.build()
        
        print("Gini Vision Library for iOS (\(GINIVision.versionString)) / Client id: \(clientId)")

        return true
    }
    
    func populateSettingsPage() {
        UserDefaults.standard.setValue(GINIVision.versionString, forKey: kSettingsGiniVisionVersionKey)
        UserDefaults.standard.setValue(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, forKey: kSettingsExampleAppVersionKey)
        UserDefaults.standard.synchronize()
    }
    
}
