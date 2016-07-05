//
//  GINIVision.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Delegate to inform the reveiver about the current status of the Gini Vision Library.
 Makes use of callbacks for handling incoming data and to control view controller presentation.
 
 - note: Screen API only.
 */
@objc public protocol GINIVisionDelegate {
    
    /**
     Called when the user has taken an image.
     
     - parameter imageData: JPEG image data including meta information.
     */
    func didCapture(imageData: NSData)
    
    /**
     Called when the user has reviewed the image and potentially rotated it to the correct orientation.
     
     - parameter imageData: JPEG image data including eventually updated meta information.
     - parameter changes:   Indicates whether `imageData` was altered.
    */
    func didReview(imageData: NSData, withChanges changes: Bool)
    
    /**
     Called when the user cancels capturing on the camera screen. Should be used to dismiss the presented view controller.
     */
    func didCancelCapturing()
    
    /**
     Called when the user navigates back from the review screen to the camera potentially to retake an image. Should be used to cancel any ongoing analysis task on the image.
     */
    optional func didCancelReview()
    
    /**
     Called when the user is presented with the analsis screen. Use the `analysisDelegate` object to inform the user about the current status of the analysis task.
     
     - parameter analysisDelegate: The analsis delegate to send updates to.
     */
    optional func didShowAnalysis(analysisDelegate: GINIAnalysisDelegate)
    
    /**
     Called when the user navigates back from the analysis screen to the review screen. Should be used to cancel any ongoing analysis task on the image.
     */
    optional func didCancelAnalysis()
    
}

/**
 Convenience class to interact with the Gini Vision Library.
 
 The Gini Vision Library provides views for capturing, reviewing and analysing documents.
 
 By integrating this library in your application you can allow your users to easily take a picture of a document, review it and - by implementing the necessary callbacks - upload the document for analysis to the Gini API.
 
 The Gini Vision Library can be integrated in two ways, either by using the **Screen API** or the **Component API**. The Screen API provides a fully pre-configured navigation controller for easy integration, while the Component API provides single view controllers for advanced integration with more freedom for customization.
 
 - important: When using the Component API we advise you to use a similar flow as suggested in the Screen API. Use the `GINICameraViewController` as an entry point with the `GINIOnboardingViewController` presented on top of it. After capturing let the user review the document with the `GINIReviewViewController` and finally present the `GINIAnalysisViewController` while the user waits for the analysis results.
 */
@objc public final class GINIVision: NSObject {
    
    /**
     Sets a configuration which is used to customize the look and feel of the Gini Vision Library,
     for example to change texts and colors displayed to the user.
     
     - parameter configuration: The configuration to set.
     */
    public class func setConfiguration(configuration: GINIConfiguration) {
        if configuration.debugModeOn {
            print("GiniVision: Set mode to DEBUG (WARNING: Never make a release in DEBUG mode!)")
        }
        GINIConfiguration.sharedConfiguration = configuration // TODO: Make a copy to avoid changes during usage
    }
    
    /**
     Returns a navigation view controller with the camera screen loaded and ready to go. It's the easiest way to get started with the Gini Vision Library as it comes pre-configured and handles all screens and transitions out of the box.
     
     - note: Screen API only.
     
     - parameter delegate: An instance conforming to the `GINIVisionDelegate` protocol.
     
     - returns: A presentable navigation view controller.
     */
    public class func viewController(withDelegate delegate: GINIVisionDelegate) -> UIViewController {
        let cameraContainerViewController = GINICameraContainerViewController()
        let navigationController = GININavigationViewController(rootViewController: cameraContainerViewController)
        navigationController.giniDelegate = delegate
        return navigationController
    }
    
    /**
     Returns a navigation view controller with the camera screen loaded and ready to go. Allows to set a custom configuration to change the look and feel of the Gini Vision Library.
     
     - note: Screen API only.
     
     - parameter delegate:      An instance conforming to the `GINIVisionDelegate` protocol.
     - parameter configuration: The configuration to set.
     
     - returns: A presentable navigation view controller.
     */
    public class func viewController(withDelegate delegate: GINIVisionDelegate, withConfiguration configuration: GINIConfiguration) -> UIViewController {
        setConfiguration(configuration)
        return viewController(withDelegate: delegate)
    }
    
}
