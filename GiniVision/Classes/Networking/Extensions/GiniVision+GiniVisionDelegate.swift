//
//  GiniVision+GiniVisionDelegate.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import Foundation

extension GiniVision {
    @objc public class func viewController(withClient client: GiniClient,
                                           importedDocuments: [GiniVisionDocument]? = nil,
                                           giniConfiguration: GiniConfiguration,
                                           resultsDelegate: GiniVisionResultsDelegate) -> UIViewController {
        GiniVision.setConfiguration(giniConfiguration)
        let screenCoordinator = GiniScreenAPICoordinator(client: client,
                                                         resultsDelegate: resultsDelegate,
                                                         giniConfiguration: giniConfiguration)
        return screenCoordinator.start(withDocuments: importedDocuments)
    }
    
}
