//
//  GiniVision+GiniVisionDelegate.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import Foundation

extension GiniVision {
    public class func viewController(withCredentials credentials: (id: String?, password: String?),
                                     importedDocument: GiniVisionDocument? = nil,
                                     giniConfiguration: GiniConfiguration) -> UIViewController {
        GiniConfiguration.sharedConfiguration = giniConfiguration
        let screenCoordinator = GiniScreenAPICoordinator(credentials: credentials,
                                                         giniConfiguration: giniConfiguration)
        return screenCoordinator.start(withDocument: importedDocument)
    }
    
}
