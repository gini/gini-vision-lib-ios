//
//  GiniScreenAPICoordinator+Pinning.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//

import Foundation
import Gini

extension GiniScreenAPICoordinator {
    convenience init(client: Client,
                     resultsDelegate: GiniVisionResultsDelegate,
                     giniConfiguration: GiniConfiguration,
                     publicKeyPinningConfig: [String: Any],
                     documentMetadata: Document.Metadata?,
                     api: APIDomain) {
        self.init(withDelegate: nil,
                  giniConfiguration: giniConfiguration)
        self.visionDelegate = self
        self.resultsDelegate = resultsDelegate
        let sdk = GiniSDK
            .Builder(client: client, api: api, pinningConfig: publicKeyPinningConfig)
            .build()
        
        self.documentService = documentService(with: sdk,
                                               documentMetadata: documentMetadata,
                                               giniConfiguration: giniConfiguration,
                                               for: api)
    }
}
