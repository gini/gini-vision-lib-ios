//
//  GiniNetworkingScreenAPICoordinator+Pinning.swift
//  GiniVision
//
//  Created by Nadya Karaban on 07.10.20.
//

import Foundation
import Gini

extension GiniNetworkingScreenAPICoordinator {
    convenience init(client: Client,
                     resultsDelegate: GiniVisionResultsDelegate,
                     giniConfiguration: GiniConfiguration,
                     publicKeyPinningConfig: [String: Any],
                     documentMetadata: Document.Metadata?,
                     api: APIDomain,
                     trackingDelegate: GiniVisionTrackingDelegate?) {
        
        let sdk = GiniSDK
            .Builder(client: client,
                     api: api,
                     pinningConfig: publicKeyPinningConfig)
            .build()

        self.init(client: client,
                  resultsDelegate: resultsDelegate,
                  giniConfiguration: giniConfiguration,
                  documentMetadata: documentMetadata,
                  api: api,
                  trackingDelegate: trackingDelegate,
                  sdk: sdk)
    }
}
