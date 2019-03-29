//
//  GiniVision+GiniVisionDelegate.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/14/18.
//

import Foundation
import Gini_iOS_SDK

extension GiniVision {
    /**
     Returns a view controller which will handle the analysis process.
     It's the easiest way to get started with the Gini Vision Library as it comes pre-configured and handles
     all screens and transitions out of the box, including the networking.
     
     - parameter client: `GiniClient` with the information needed to enable document analysis
     - parameter configuration: The configuration to set.
     - parameter importedDocuments: Documents that come from a source different than CameraViewController.
     There should be either images or one PDF, and they should be validated before calling this method.
     - parameter resultsDelegate: Results delegate object where you can get the results of the analysis.
     - parameter documentMetadata: (Optional) The document metadata containing any custom information regarding
     the upload (used later for reporting).
     - parameter docType: (Optional) Document type hint.
     - parameter api: The `GINIAPIType` the SDK connects to.
     
     - note: Screen API only.

     - returns: A presentable view controller.
     */
    @objc public class func viewController(withClient client: GiniClient,
                                           importedDocuments: [GiniVisionDocument]? = nil,
                                           configuration: GiniConfiguration,
                                           resultsDelegate: GiniVisionResultsDelegate,
                                           documentMetadata: GINIDocumentMetadata? = nil,
                                           docType: DocType = .none,
                                           api: GINIAPIType = .default) -> UIViewController {
        GiniVision.setConfiguration(configuration)
        let screenCoordinator = GiniScreenAPICoordinator(client: client,
                                                         resultsDelegate: resultsDelegate,
                                                         giniConfiguration: configuration,
                                                         documentMetadata: documentMetadata,
                                                         docType: docType,
                                                         api: api)
        return screenCoordinator.start(withDocuments: importedDocuments)
    }
    
}
