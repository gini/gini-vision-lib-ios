//
//  GINIConfiguration.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import Foundation

/**
 The `GINIConfiguration` class allows customizations to the look and feel of the Gini Vision Library. If there are limitations regarding which API can be used, this is clearly stated for the specific attribute.
 
 - note: Text can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle. The library will prefer whatever value is set in the following order: attribute in configuration, key in strings file in project bundle, key in strings file in `GiniVision` bundle.
 - note: Images can only be set by providing images with the same filename in an assets file or as individual files in the projects bundle. The library will prefer whatever value is set in the following order: asset file in project bundle, asset file in `GiniVision` bundle.
 - attention: If there are conflicting pairs of image and text for an interface element (e.g. `navigationBarCameraTitleCloseButton`) the image will always be preferred, while making sure the accessibility label is set.
 */
@objc public final class GINIConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini Vision Library.
     */
    internal static var sharedConfiguration = GINIConfiguration()
    
    /**
     Shorthand check if debug mode is turned on.
     */
    internal static var DEBUG: Bool {
        return sharedConfiguration.debugModeOn
    }
    
    
    
    // MARK: General options
    /**
     Can be turned on during development to unlock extra information and to save captured images to camera roll.
    
     - warning: Should never be used outside of a development enviroment.
     */
    public var debugModeOn = false
    
    /**
     Sets the background color in all screens of the Gini Vision Library to the specified color.
 
     - note: Screen API only.
     */
    public var backgroundColor = UIColor.blackColor()
    
    /**
     Sets the tint color of the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color.
    
     - note: Screen API only.
     */
    public var navigationBarTintColor = UINavigationBar.appearance().barTintColor ?? Colors.Gini.blue
    
    /**
     Sets the tint color of all navigation items in all screens of the Gini Vision Library to the globally specified color.
 
     - note: Screen API only.
     */
    public var navigationBarItemTintColor = UINavigationBar.appearance().tintColor
    
    /**
     Sets the font of all navigation items in all screens of the Gini Vision Library to the globally specified font or a default font.
     
     - note: Screen API only.
     */
    public var navigationBarItemFont = UIBarButtonItem.appearance().titleTextAttributesForState(.Normal)?[NSFontAttributeName] as? UIFont ?? UIFontPreferred(.Regular, andSize: 16)
    
    /**
     Sets the title color in the navigation bar in all screens of the Gini Vision Library to the globally specified color or to a default color.
     
     - note: Screen API only.
     */
    public var navigationBarTitleColor = UINavigationBar.appearance().titleTextAttributes?[NSForegroundColorAttributeName] as? UIColor ?? Colors.Gini.lightBlue
    
    /**
     Sets the title font in the navigation bar in all screens of the Gini Vision Library to the globally specified font or to a default font.
     
     - note: Screen API only.
     */
    public var navigationBarTitleFont = UINavigationBar.appearance().titleTextAttributes?[NSFontAttributeName] as? UIFont ?? UIFontPreferred(.Light, andSize: 16)
    
    /** 
     Sets the background color of an informal notice. Notices are small pieces of information appearing underneath the navigation bar.
     */
    public var noticeInformationBackgroundColor = UIColor.blackColor()
    
    /**
     Sets the text color of an informal notice. Notices are small pieces of information appearing underneath the navigation bar.
     */
    public var noticeInformationTextColor = UIColor.whiteColor()
    
    /**
     Sets the background color of an error notice. Notices are small pieces of information appearing underneath the navigation bar.
     */
    public var noticeErrorBackgroundColor = UIColor.redColor()
    
    /**
     Sets the text color of an error notice. Notices are small pieces of information appearing underneath the navigation bar.
     */
    public var noticeErrorTextColor = UIColor.whiteColor()
    
    /** 
     Sets the font of all notices. Notices are small pieces of information appearing underneath the navigation bar.
     */
    public var noticeFont = UIFontPreferred(.Regular, andSize: 12)
    
    
    
    // MARK: Camera options
    /**
     Sets the title text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    public var navigationBarCameraTitle = NSLocalizedStringPreferred("ginivision.navigationbar.camera.title", comment: "Title in the navigation bar on the camera screen")
    
    /**
     Sets the close button text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    public var navigationBarCameraTitleCloseButton = NSLocalizedStringPreferred("ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen")
    
    /**
     Sets the help button text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    public var navigationBarCameraTitleHelpButton = NSLocalizedStringPreferred("ginivision.navigationbar.camera.help", comment: "Button title in the navigation bar for the help button on the camera screen")
    
    /**
     Sets the text for the accessibility label of the capture button which allows the user to capture an image of a document.
     
     - note: Used exclusively for accessibility label.
     */
    public var cameraCaptureButtonTitle = NSLocalizedStringPreferred("ginivision.camera.captureButton", comment: "Title for capture button in camera screen will be used exclusively for accessibility label")
    
    /**
     Sets the descriptional text when camera access was denied, advising the user to authorize the camera in the settings application.
     */
    public var cameraNotAuthorizedText = NSLocalizedStringPreferred("ginivision.camera.notAuthorized", comment: "Description text when the camera is not authorized and the user is advised to change that in the settings app")
    
    /**
     Sets the font of the descriptional text when camera access was denied.
     */
    public var cameraNotAuthorizedTextFont = UIFontPreferred(.Thin, andSize: 20)
    
    /**
     Sets the text color of the descriptional text when camera access was denied.
     */
    public var cameraNotAuthorizedTextColor = UIColor.whiteColor()
    
    /**
     Sets the button title when camera access was denied, clicking the button will open the settings application.
     */
    public var cameraNotAuthorizedButtonTitle = NSLocalizedStringPreferred("ginivision.camera.notAuthorizedButton", comment: "Button title to open the settings app")
    
    /**
     Sets the font of the button title when camera access was denied.
     */
    public var cameraNotAuthorizedButtonFont = UIFontPreferred(.Regular, andSize: 20)
    
    /**
     Sets the text color of the button title when camera access was denied.
     */
    public var cameraNotAuthorizedButtonTitleColor = UIColor.whiteColor()
    
    
    
    // MARK: Onboarding options
    /**
     Sets the title text in the navigation bar on the onboarding screen.
     
     - note: Screen API only.
     */
    public var navigationBarOnboardingTitle = NSLocalizedStringPreferred("ginivision.navigationbar.onboarding.title", comment: "Title in the navigation bar on the onboarding screen")
    
    /**
     Sets the continue button text in the navigation bar on the onboarding screen.
     
     - note: Screen API only.
     */
    public var navigationBarOnboardingTitleContinueButton = NSLocalizedStringPreferred("ginivision.navigationbar.onboarding.continue", comment: "Button title in the navigation bar for the continue button on the onboarding screen")
    
    /**
     Sets the color of the page controller's page indicator items.
     */
    public var onboardingPageIndicatorColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    
    /**
     Sets the color of the page controller's current page indicator item.
     */
    public var onboardingCurrentPageIndicatorColor = UIColor.whiteColor()
    
    /**
     Indicates whether the onboarding screen should be presented at each start of the Gini Vision Library.
     
     - note: Screen API only.
     */
    public var onboardingShowAtLaunch = false
    
    /**
     Indicates whether the onboarding screen should be presented at the first start of the Gini Vision Library. It is advised to do so.
     
     - note: Overwrites `onboardingShowAtLaunch` for the first launch.
     - note: Screen API only.
     */
    public var onboardingShowAtFirstLaunch = true
    
    /**
     Sets the text on the first onboarding page.
     */
    public var onboardingFirstPageText = NSLocalizedStringPreferred("ginivision.onboarding.firstPage", comment: "Text on the first page of the onboarding screen")
    
    /**
     Sets the text on the second onboarding page.
     */
    public var onboardingSecondPageText = NSLocalizedStringPreferred("ginivision.onboarding.secondPage", comment: "Text on the second page of the onboarding screen")
    
    /**
     Sets the text on the third onboarding page.
     */
    public var onboardingThirdPageText = NSLocalizedStringPreferred("ginivision.onboarding.thirdPage", comment: "Text on the third page of the onboarding screen")
    
    /**
     Sets the font of the text for all onboarding pages.
     */
    public var onboardingTextFont = UIFontPreferred(.Thin, andSize: 28)
    
    /**
     Sets the color ot the text for all onboarding pages.
     */
    public var onboardingTextColor = UIColor.whiteColor()
    
    /**
     All onboarding pages which will be presented in a horizontal scroll view to the user. By default the Gini Vision Library comes with three pages advising the user to keep the document flat, hold the device parallel and capture the whole document.
     
     - note: Any array of views can be passed, but for your convenience we provide the `GINIOnboardingPage` class.
     */
    public var onboardingPages: [UIView] {
        get {
            if let pages = onboardingPrivatePages {
                return pages
            }
            guard let page1 = GINIOnboardingPage(imageNamed: "onboardingPage1", text: onboardingFirstPageText),
                  let page2 = GINIOnboardingPage(imageNamed: "onboardingPage2", text: onboardingSecondPageText),
                  let page3 = GINIOnboardingPage(imageNamed: "onboardingPage3", text: onboardingThirdPageText) else {
                    return [UIView]()
            }
            let pages = [page1, page2, page3]
            onboardingPrivatePages = pages
            return onboardingPrivatePages!
        }
        set {
            self.onboardingPrivatePages = newValue
        }
    }
    private var onboardingPrivatePages: [UIView]?
    
    
    
    // MARK: Review options
    /**
     Sets the title text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    public var navigationBarReviewTitle = NSLocalizedStringPreferred("ginivision.navigationbar.review.title", comment: "Title in the navigation bar on the review screen")
    
    /**
     Sets the back button text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    public var navigationBarReviewTitleBackButton = NSLocalizedStringPreferred("ginivision.navigationbar.review.back", comment: "Button title in the navigation bar for the back button on the review screen")
    
    /**
     Sets the continue button text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    public var navigationBarReviewTitleContinueButton = NSLocalizedStringPreferred("ginivision.navigationbar.review.continue", comment: "Button title in the navigation bar for the continue button on the review screen")
    
    /**
     Sets the text appearing at the top of the review screen which should ask the user if the whole document is in focus and has correct orientation.
     */
    public var reviewTextTop = NSLocalizedStringPreferred("ginivision.review.top", comment: "Text at the top of the review screen asking the user if the full document is sharp and in the correct orientation")
    
    /**
     The text at the top of the review screen is displayed as a notice and can not be set individually.
     
     - seeAlso: `noticeFont`
     */
    public var reviewTextTopFont: UIFont {
        return noticeFont
    }
    
    /**
     Sets the text for the accessibility label of the rotate button which allows the user to rotate the docuent into reading direction.
     
     - note: Used exclusively for accessibility label.
     */
    public var reviewRotateButtonTitle = NSLocalizedStringPreferred("ginivision.review.rotateButton", comment: "Title for rotate button in review screen will be used exclusively for accessibility label")
    
    /**
     Sets the text for the accessibility label of the document image view.
     
     - note: Used exclusively for accessibility label.
     */
    public var reviewDocumentImageTitle = NSLocalizedStringPreferred("ginivision.review.documentImageTitle", comment: "Title for document image in review screen will be used exclusively for accessibility label")
    
    /**
     Sets the background color of the bottom section on the review screen containing the rotation button.
     
     - note: Background will have a 20% transparency, to have enough space for the document image on smaller devices.
     */
    public var reviewBottomViewBackgroundColor = UIColor.blackColor()
    
    /**
     Sets the text appearing at the bottom of the review screen which should encourage the user to check sharpness by double-tapping the image.
     */
    public var reviewTextBottom = NSLocalizedStringPreferred("ginivision.review.bottom", comment: "Text at the bottom of the review screen encouraging the user to check sharpness by double-tapping the image")
    
    /**
     Sets the font of the text appearing at the bottom of the review screen.
     */
    public var reviewTextBottomFont = UIFontPreferred(.Thin, andSize: 12)
    
    /**
     Sets the color of the text appearing at the bottom of the review screen.
     */
    public var reviewTextBottomColor = UIColor.whiteColor()
    
    
    
    
    
    // MARK: Analysis options
    /**
     Sets the title text in the navigation bar on the analysis screen.
     
     - note: Screen API only.
     */
    public var navigationBarAnalysisTitle = NSLocalizedStringPreferred("ginivision.navigationbar.analysis.title", comment: "Title in the navigation bar on the analysis screen")
    
    /** 
     Sets the back button text in the navigation bar on the analysis screen.
     */
    public var navigationBarAnalysisTitleBackButton = NSLocalizedStringPreferred("ginivision.navigationbar.analysis.back", comment: "Button title in the navigation bar for the back button on the analysis screen")
    
    /**
     Sets the color of the loading indicator on the analysis screen to the specified color.
     */
    public var analysisLoadingIndicatorColor = UIColor.whiteColor()
    
    
    
    /**
     Returns a `GiniConfiguration` instance which allows to set individual configurations to change the look and feel of the Gini Vision Library.
     
     - returns: Instance of `GiniConfiguration`.
     */
    public override init() {}
        
}

internal struct Colors {
    
    struct Gini {
        
        static var blue = Colors.UIColorHex(0x009edc)
        static var lightBlue = Colors.UIColorHex(0x74d1f5)
        
    }
    
    private static func UIColorHex(hex: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
