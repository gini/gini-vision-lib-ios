//
//  ScreenAPIViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 05/30/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import GiniVision
import Gini_iOS_SDK

protocol SelectAPIViewControllerDelegate: class {
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniVisionAPIType)
    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ())
}

/**
 Integration options for Gini Vision library.
 */
enum GiniVisionAPIType {
    case screen
    case component
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Vision Library for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationButton: UIButton!
    
    weak var delegate: SelectAPIViewControllerDelegate?

    private lazy var clientID: String? = {
        var keys: NSDictionary?
        let clientID = "client_id"
        
        if let path = Bundle.main.path(forResource: "Credentials", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[clientID] as? String,
            !client_id.isEmpty {
            
            return client_id
        }
        return ProcessInfo.processInfo.environment[clientID]
    }()
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let clientId = self.clientID ?? ""
        
        let metaTitle = "Gini Vision Library: (\(GiniVision.versionString)) / Client id: \(clientId)"
        metaInformationButton.setTitle(metaTitle, for: .normal)
        
    }
    
    // MARK: User interaction
    @IBAction func launchScreenAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .screen)
    }

    @IBAction func launchComponentAPI(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectApi: .component)
    }
    
    @IBAction func launchSettings(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didTapSettings: ())
    }
    
}
