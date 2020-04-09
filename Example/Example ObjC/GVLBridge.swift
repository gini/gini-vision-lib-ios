//
//  GVLBridge.swift
//  Example ObjC
//
//  Created by Maciej Trybilo on 09.04.20.
//  Copyright © 2020 Gini GmbH. All rights reserved.
//

import Foundation
import GiniVision
import Gini

@objc class GVLBridge: NSObject {
    
    @objc static func viewController(clientId: String,
                               secret: String,
                               domain: String,
                               giniConfiguration: GiniConfiguration,
                               resultsDelegate: GiniVisionResultsDelegate) -> UIViewController {
        
        return GiniVision.viewController(withClient: Client(id: clientId, secret: secret, domain: domain),
                                         configuration: giniConfiguration,
                                         resultsDelegate: resultsDelegate)
    }
}
