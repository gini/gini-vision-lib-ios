//
//  AnalysisManager.swift
//  GiniVision
//
//  Created by Peter Pult on 10/08/2016.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import Gini_iOS_SDK
import GiniVision

let GINIAnalysisManagerDidReceiveResultNotification = "GINIAnalysisManagerDidReceiveResultNotification"
let GINIAnalysisManagerDidReceiveErrorNotification  = "GINIAnalysisManagerDidReceiveErrorNotification"
let GINIAnalysisManagerResultDictionaryUserInfoKey  = "GINIAnalysisManagerResultDictionaryUserInfoKey"
let GINIAnalysisManagerErrorUserInfoKey             = "GINIAnalysisManagerErrorUserInfoKey"
let GINIAnalysisManagerDocumentUserInfoKey          = "GINIAnalysisManagerDocumentUserInfoKey"

typealias DocumentAnalysisCompletion = (([String: GINIExtraction]?, GINIDocument?, Error?) -> Void)

/**
 Provides a manager class to show how to get extractions from a document image using the Gini SDK for iOS.
 */
final class DocumentService {
    
    /**
     GiniSDK property to have global access to the Gini API.
     */
    
    var giniSDK: GiniSDK?
    
    /**
     Most current result dictionary from analysis.
     */
    var result: [String: GINIExtraction]?
    
    /**
     Most current analyzed document.
     */
    var document: GINIDocument?
    
    /**
     Most current error that occured during analysis.
     */
    var error: Error?
    
    /**
     Whether a analysis process is in progress.
     */
    var isAnalyzing = false
    
    fileprivate var cancelationToken: CancelationToken?
    enum AnalysisError: Error {
        case documentCreation
        case unknown
    }
    
    /**
     Cancels all running analysis processes manually.
     */
    func cancelAnalysis() {
        cancelationToken?.cancel()
        result = nil
        document = nil
        error = nil
        isAnalyzing = false
    }
    
    let clientID = "client_id"
    let clientPassword = "client_password"
    
    private lazy var credentials: (id: String?, password: String?) = {
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Credentials", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let client_id = keys[self.clientID] as? String,
            let client_password = keys[self.clientPassword] as? String,
            !client_id.isEmpty, !client_password.isEmpty {
            
            return (client_id, client_password)
        }
        return (ProcessInfo.processInfo.environment[self.clientID],
                ProcessInfo.processInfo.environment[self.clientPassword])
    }()
    
    init() {
        let clientId = credentials.id ?? ""
        let clientSecret = credentials.password ?? ""
        
        // Set up GiniSDK with your credentials.
        let builder = GINISDKBuilder.anonymousUser(withClientID: clientId,
                                                   clientSecret: clientSecret,
                                                   userEmailDomain: "example.com")
        
        self.giniSDK = builder?.build()
        
        print("Gini Vision Library for iOS (\(GiniVision.versionString)) / Client id: \(clientId)")
    }
    
    /**
     Analyzes the given image data returning possible extraction values.
     
     - note: Only one analysis process can be running at a time.
     
     - parameter data:             The image data to be analyzed.
     - parameter cancelationToken: The cancelation token.
     - parameter completion:       The completion block handling the result.
     */
    func analyzeDocument(withData data: Data,
                         cancelationToken token: CancelationToken,
                         completion: DocumentAnalysisCompletion?) {

    }
    
    /*
     If a valid document is set, send feedback on it.
     This is just to show case how to give feedback using the Gini SDK for iOS.
     In a real world application feedback should be triggered after the user
     has evaluated and eventually corrected the extractions.
     
     - parameter document: Gini document.
     
     */
    func sendFeedback(forDocument document: GINIDocument) {
        
    }
    
}

