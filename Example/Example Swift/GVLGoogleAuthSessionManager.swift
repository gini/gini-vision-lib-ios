//
//  GVLGoogleAuthSessionManager.swift
//  Example Swift
//
//  Created by Alpár Szotyori on 20.09.19.
//  Copyright © 2019 Gini GmbH. All rights reserved.
//

import Foundation
import GiniVision
import Gini_iOS_SDK

class GVLGoogleAuthSessionManager: GINISessionManager {
    
    /**
     Gym API
     */
    static let GymApiLoginEndpoint = "google_login"
    let gymApiBaseUrl: String
        
    /**
     Google auth info
    */
    var email = ""
    var idToken = ""
    
    /**
     The user's current session.
    */
    var currentSession: GINISession?
    
    /**
     The current task to get a new session.
    */
    var currentSessionTask: BFTask<AnyObject>?
    
    init(withGymApiBaseUrl baseUrl:String) {
        self.gymApiBaseUrl = baseUrl
        super.init()
    }
    
    override func getSession() -> BFTask<AnyObject>! {
        let completionSource = BFTaskCompletionSource<AnyObject>()
        
        // Try to reuse an active session
        if let currentSession = currentSession {
            completionSource.set(result: currentSession)
            return completionSource.task
        }
        
        // Don't start a new request, if one is already running
        if let currentSessionTask = currentSessionTask {
            return currentSessionTask
        }
        currentSessionTask = completionSource.task

        let url = URL(string: "\(gymApiBaseUrl)/\(GVLGoogleAuthSessionManager.GymApiLoginEndpoint)")
        guard let _ = url else {
            completionSource.set(error: GINIError(code: GINIErrorCode.loginError.rawValue, userInfo: nil))
            return completionSource.task
        }
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "email=\(email)&idToken=\(idToken)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
            .data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let `self` = self else { return }
            defer {
                self.currentSessionTask = nil
            }
            if let error = error {
                completionSource.set(error: GINIError(code: GINIErrorCode.loginError.rawValue, cause: error, userInfo: nil))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                completionSource.set(error: GINIError(code: GINIErrorCode.loginError.rawValue, cause: GINIError(code: GINIErrorCode.loginError.rawValue, userInfo: nil), userInfo: nil))
                return
            }
            if let data = data {
                let decoder = JSONDecoder()
                struct Session: Decodable {
                    var access_token: String
                    var expires_in: Int
                }
                do {
                    let session = try decoder.decode(Session.self, from: data)
                    self.currentSession = GINISession(accessToken: session.access_token, refreshToken: "", expirationDate: Date(timeIntervalSinceNow: TimeInterval(session.expires_in)))
                    completionSource.set(result: self.currentSession)
                } catch {
                    completionSource.set(error: GINIError(code: GINIErrorCode.loginError.rawValue, cause: GINIError(code: GINIErrorCode.loginError.rawValue, userInfo: nil), userInfo: nil))
                }
            } else {
                completionSource.set(error: GINIError(code: GINIErrorCode.loginError.rawValue, cause: GINIError(code: GINIErrorCode.loginError.rawValue, userInfo: nil), userInfo: nil))
            }
        }
        task.resume()
        
        return completionSource.task
    }
    
    override func logIn() -> BFTask<AnyObject>! {
        return getSession()
    }
}
