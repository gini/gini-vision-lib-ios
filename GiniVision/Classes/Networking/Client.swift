//
//  Client.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/15/18.
//

import Foundation

public struct Client {
    public let clientId: String
    public let clientSecret: String
    public let clientEmailDomain: String
    
    public init(clientId: String, clientSecret: String, clientEmailDomain: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.clientEmailDomain = clientEmailDomain
    }
}
