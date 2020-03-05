//
//  Tracking.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 27.02.20.
//

import Foundation

/**
Delegate protocol that GVL uses to report user events. Implement the delegate methods
and pass the delegate to `GiniVision.viewController()` when initializing GVL.
 
The delegate is separated into smaller protocols relating to different parts of GVL.
 
- note: The delegate isn't retained by GVL. It should be retained by the client code.
*/
public protocol GiniVisionTrackingDelegate:
    OnboardingScreenTrackingDelegate
    & CameraScreenTrackingDelegate
    & ReviewScreenTrackingDelegate
    & AnalysisScreenTrackingDelegate
{}

/**
Event types relating to onboarding.
*/
public enum OnboardingScreenEventType: String {
    /// Onboarding started
    case start
    /// User completed onboarding
    case finish
}

/**
Tracking delegate relating to onboarding.
*/
public protocol OnboardingScreenTrackingDelegate: class {
    
    func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>)
}

/**
Event types relating to the camera screen.
*/
public enum CameraScreenEventType: String {
    /// User closed the camera screen
    case exit
    /// User tapped "Help" on the camera screen
    case help
    /// User took a picture
    case takePicture
}

/**
Tracking delegate relating to the camera screen.
*/
public protocol CameraScreenTrackingDelegate: class {
    
    func onCameraScreenEvent(event: Event<CameraScreenEventType>)
}

/**
Event types relating to the review screen.
*/
public enum ReviewScreenEventType: String {
    /// User went back from the review screen
    case back
    /// User advanced from the review screen
    case next
}

/**
Tracking delegate relating to the review screen.
*/
public protocol ReviewScreenTrackingDelegate: class {
    
    func onReviewScreenEvent(event: Event<ReviewScreenEventType>)
}

/**
Event types relating to the analysis screen.
*/
public enum AnalysisScreenEventType: String {
    /// User canceled the process during analysis
    case cancel
    /// The analysis ended with an error. The error message is supplied under the "message" key.
    case error
    /// The user decided to retry after an analysis error.
    case retry
}

/**
Tracking delegate relating to the analysis screen.
*/
public protocol AnalysisScreenTrackingDelegate: class {
    
    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>)
}
