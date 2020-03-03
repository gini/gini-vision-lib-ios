//
//  GiniVision+GiniVisionDelegate.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import Foundation
import Gini

extension GiniVision {
    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Vision Library as it comes pre-configured and handles
     all screens and transitions out of the box, including the networking.
     
     - parameter client: `GiniClient` with the information needed to enable document analysis
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter configuration: The configuration to set.
     - parameter documentMetadata: Additional HTTP headers to send when uploading documents
     - parameter api: The Gini backend API to use
     - parameter trackingDelegate: A delegate object to receive user events
     
     - note: Screen API only.

     - returns: A presentable view controller.
     */
    public class func viewController(withClient client: Client,
                                     importedDocuments: [GiniVisionDocument]? = nil,
                                     configuration: GiniConfiguration,
                                     resultsDelegate: GiniVisionResultsDelegate,
                                     documentMetadata: Document.Metadata? = nil,
                                     api: APIDomain = .default,
                                     trackingDelegate: GiniVisionTrackingDelegate? = nil) -> UIViewController {
        GiniVision.setConfiguration(configuration)
        let screenCoordinator = GiniNetworkingScreenAPICoordinator(client: client,
                                                         resultsDelegate: resultsDelegate,
                                                         giniConfiguration: configuration,
                                                         documentMetadata: documentMetadata,
                                                         api: api,
                                                         trackingDelegate: trackingDelegate)
        return screenCoordinator.start(withDocuments: importedDocuments)
    }
    
    public class func removeStoredCredentials(for client: Client) throws {
        let sdk = GiniSDK.Builder(client: client).build()
        
        try sdk.removeStoredCredentials()
    }
    
}
