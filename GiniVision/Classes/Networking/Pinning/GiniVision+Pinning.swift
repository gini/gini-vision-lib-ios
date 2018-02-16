//
//  GiniVision+Pinning.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//

import Foundation

extension GiniVision {
    public class func viewController(withClient client: GiniClient,
                                     importedDocument: GiniVisionDocument? = nil,
                                     giniConfiguration: GiniConfiguration,
                                     resultsDelegate: GiniVisionResultsDelegate,
                                     publicKeyPinningConfig: [String: Any]) -> UIViewController {
        GiniVision.setConfiguration(giniConfiguration)
        let screenCoordinator = GiniScreenAPICoordinator(client: client,
                                                         resultsDelegate: resultsDelegate,
                                                         giniConfiguration: giniConfiguration,
                                                         publicKeyPinningConfig: publicKeyPinningConfig)
        return screenCoordinator.start(withDocument: importedDocument)
    }
    
}
