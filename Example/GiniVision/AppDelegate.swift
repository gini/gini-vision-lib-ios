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
        guard let navVC = window?.rootViewController as? UINavigationController, let selectAPIVC = navVC.viewControllers.first as? SelectAPIViewController else {
            return false
        }
        
        // 1. Read data imported from url
        let data = try? Data(contentsOf: url)
        
        // 2. Build the document
        let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        let document = documentBuilder.build()

        // 3. Validate document
        let alertViewController:UIAlertController
        do {
            try document?.validate()
            
            // 4. Create an alert which allow users to open imported file either with the ScreenAPI or the ComponentAPI
            alertViewController = UIAlertController(title: "Importierte Datei", message: "Möchten Sie die importierte Datei mit dem ScreenAPI oder ComponentAPI verwenden?", preferredStyle: .alert)
            
            alertViewController.addAction(UIAlertAction(title: "Screen API", style: .default) { _ in
                selectAPIVC.present(selectAPIVC.giniScreenAPI(withImportedDocument: document), animated: true, completion: nil)
            })
            
            alertViewController.addAction(UIAlertAction(title: "Component API", style: .default) { _ in
                let componentAPICoordinator = ComponentAPICoordinator(document: document)
                componentAPICoordinator.start(from: selectAPIVC)
            })
        } catch {
            // 4.1. Create alert which shows an error pointing out that it is not a valid document
            alertViewController = UIAlertController(title: "Ungültiges Dokument", message: "Dies ist kein gültiges Dokument", preferredStyle: .alert)
            alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                alertViewController.dismiss(animated: true, completion: nil)
            })
        }
        
        // 5. Present alert
        selectAPIVC.present(alertViewController, animated: true, completion: nil)
        
        return true
    }
    
    func populateSettingsPage() {
        UserDefaults.standard.setValue(GiniVision.versionString, forKey: kSettingsGiniVisionVersionKey)
        UserDefaults.standard.setValue(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, forKey: kSettingsExampleAppVersionKey)
        UserDefaults.standard.synchronize()
    }
    
}

