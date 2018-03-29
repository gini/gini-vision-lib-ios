//
//  GiniScreenAPICoordinator+Pinning.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//

import Foundation
import Gini_iOS_SDK

extension GiniScreenAPICoordinator {
    convenience init(client: GiniClient,
                     resultsDelegate: GiniVisionResultsDelegate,
                     giniConfiguration: GiniConfiguration,
                     publicKeyPinningConfig: [String: Any]) {
        self.init(withDelegate: nil,
                  giniConfiguration: giniConfiguration)
        self.visionDelegate = self
        self.resultsDelegate = resultsDelegate
        
        let builder = GINISDKBuilder.anonymousUser(withClientID: client.clientId,
                                                   clientSecret: client.clientSecret,
                                                   userEmailDomain: client.clientEmailDomain,
                                                   publicKeyPinningConfig: publicKeyPinningConfig)
        if let sdk = builder?.build() {
            self.documentService = CompositeDocumentService(sdk: sdk)
        }
    }
}
