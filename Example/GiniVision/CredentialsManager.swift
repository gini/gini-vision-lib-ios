//
//  CredentialsManager.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import GiniVision

final class CredentialsManager {

    class func fetchClientFromBundle() -> GiniClient {
        let clientID = "client_id"
        let clientPassword = "client_password"
        let clientEmailDomain = "client_domain"
        let credentialsPlistPath = Bundle.main.path(forResource: "Credentials", ofType: "plist")
        
        if let path = credentialsPlistPath,
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[clientID] as? String,
            let client_password = keys[clientPassword] as? String,
            let client_email_domain = keys[clientEmailDomain] as? String,
            !client_id.isEmpty, !client_password.isEmpty, !client_email_domain.isEmpty {
            
            return GiniClient(clientId: client_id,
                              clientSecret: client_password,
                              clientEmailDomain: client_email_domain)
        }
        return GiniClient(clientId: "",
                          clientSecret: "",
                          clientEmailDomain: "")
    }
}
