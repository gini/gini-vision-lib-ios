//
//  CredentialsManager.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 2/16/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import Gini

final class CredentialsManager {

    class func fetchClientFromBundle() -> Client {
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
            
            return Client(id: client_id,
                          secret: client_password,
                          domain: client_email_domain)
        }
        return Client(id: "",
                      secret: "",
                      domain: "")
    }
}
