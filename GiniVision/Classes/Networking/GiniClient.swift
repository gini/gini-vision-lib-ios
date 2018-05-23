//
//  GiniClient.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation

/**
 GiniClient used to enable document analysis in the _Gini Vision Library_
 */
@objc public final class GiniClient: NSObject {
    public let clientId: String
    public let clientSecret: String
    public let clientEmailDomain: String
    
    @objc public init(clientId: String, clientSecret: String, clientEmailDomain: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.clientEmailDomain = clientEmailDomain
    }
}
