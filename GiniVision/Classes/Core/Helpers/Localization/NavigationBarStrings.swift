//
//  NavigationBarStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum NavigationBarStrings: LocalizableStringResource {
    
    case analysisTitle, cameraTitle, onboardingTitle, reviewTitle
    
    var tableName: String {
        return "navigationbar"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .analysisTitle:
            return ("analysis.title", "Title in the navigation bar on the analysis screen")
        case .cameraTitle:
            return ("camera.title", "Title in the navigation bar on the camera screen")
        case .onboardingTitle:
            return ("onboarding.title", "Title in the navigation bar on the onboarding screen")
        case .reviewTitle:
            return ("review.title", "Title in the navigation bar on the review screen")
        }
    }
    
    var customizable: Bool {
        return true
    }
    
    var args: CVarArg? {
        return nil
    }
    
    
}
