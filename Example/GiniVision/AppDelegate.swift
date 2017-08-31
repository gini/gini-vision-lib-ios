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
        
        print("Gini Vision Library for iOS (\(GiniVision.versionString)) / Client id: \(clientId)")

        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // If the current root view controller is not the ScreenAPIViewController not action done
        guard let navVC = window?.rootViewController as? UINavigationController, let screenAPIVC = navVC.viewControllers.first as? ScreenAPIViewController else {
            return false
        }
        
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.navigationBarItemTintColor = UIColor.white
        
        _ = url.startAccessingSecurityScopedResource()
        let data = try? Data(contentsOf: url)
        url.stopAccessingSecurityScopedResource()
        // 2. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
        let vc = GiniVision.viewController(withDelegate: screenAPIVC, withConfiguration: giniConfiguration, importedFile: data)
        
        // 3. Present the Gini Vision Library Screen API modally
        screenAPIVC.present(vc, animated: true, completion: nil)
        
        return true
    }
    
    func populateSettingsPage() {
        UserDefaults.standard.setValue(GiniVision.versionString, forKey: kSettingsGiniVisionVersionKey)
        UserDefaults.standard.setValue(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, forKey: kSettingsExampleAppVersionKey)
        UserDefaults.standard.synchronize()
    }
    
}
