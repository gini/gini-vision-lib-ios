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
    case start
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
    case exit
    case help
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
    case back
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
    case cancel
    case error
    case retry
}

/**
Tracking delegate relating to the analysis screen.
*/
public protocol AnalysisScreenTrackingDelegate: class {
    
    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>)
}
