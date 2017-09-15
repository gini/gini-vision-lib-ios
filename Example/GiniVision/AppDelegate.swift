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
        // This is only a shortcut for demo purposes since if the current root view controller is not
        // the ScreenAPIViewController (a GiniVisionDelegate), it won't do anything.
        guard let navVC = window?.rootViewController as? UINavigationController, let screenAPIVC = navVC.viewControllers.first as? ScreenAPIViewController else {
            return false
        }
        
        // 1. Read data imported from url
        let data = try? Data(contentsOf: url)
        
        // 2. Create alert which allows user to open imported file either with ScreenAPI or ComponentAPI

        let alertViewController = UIAlertController(title: "Importierte Datei", message: "Möchten Sie die importierte Datei mit dem ScreenAPI oder ComponentAPI verwenden?", preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Screen API", style: .default) { _ in
            screenAPIVC.present(screenAPIVC.giniScreenAPI(withImportedFile: data), animated: true, completion: nil)
        })
        
        alertViewController.addAction(UIAlertAction(title: "Component API", style: .default) { _ in
            if let componentAPI = screenAPIVC.giniComponentAPI(withImportedFile: data) {
                screenAPIVC.present(componentAPI, animated: true, completion: nil)
            }
        })

        // 3. Present alert with both options
        screenAPIVC.present(alertViewController, animated: true, completion: nil)
        
        return true
    }
    
    func populateSettingsPage() {
        UserDefaults.standard.setValue(GiniVision.versionString, forKey: kSettingsGiniVisionVersionKey)
        UserDefaults.standard.setValue(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, forKey: kSettingsExampleAppVersionKey)
        UserDefaults.standard.synchronize()
    }
    
}

