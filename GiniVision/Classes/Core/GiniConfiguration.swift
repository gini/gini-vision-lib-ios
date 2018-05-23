//
//  GiniConfiguration.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `GiniConfiguration` class allows customizations to the look and feel of the Gini Vision Library.
 If there are limitations regarding which API can be used, this is clearly stated for the specific attribute.
 
 - note: Text can also be set by using the appropriate keys in a `Localizable.strings` file in the projects bundle.
         The library will prefer whatever value is set in the following order: attribute in configuration,
         key in strings file in project bundle, key in strings file in `GiniVision` bundle.
 - note: Images can only be set by providing images with the same filename in an assets file or as individual files
         in the projects bundle. The library will prefer whatever value is set in the following order: asset file
         in project bundle, asset file in `GiniVision` bundle.
 - attention: If there are conflicting pairs of image and text for an interface element
              (e.g. `navigationBarCameraTitleCloseButton`) the image will always be preferred,
              while making sure the accessibility label is set.
 */
// swiftlint:disable file_length
@objc public final class GiniConfiguration: NSObject {
    
    /**
     Singleton to make configuration internally accessible in all classes of the Gini Vision Library.
     */
    internal static var shared = GiniConfiguration()
    
    /**
     Shorthand check if debug mode is turned on.
     */
    internal static var DEBUG: Bool {
        return shared.debugModeOn
    }
    
    /**
     Supported document types by Gini Vision library.
    */
    
    @objc public enum GiniVisionImportFileTypes: Int {
        case none
        case pdf
        case pdf_and_images
    }
    
    /**
     Returns a `GiniConfiguration` instance which allows to set individual configurations
     to change the look and feel of the Gini Vision Library.
     
     - returns: Instance of `GiniConfiguration`.
     */
    public override init() {}
    
    // MARK: General options
    
    /**
     Sets the background color in all screens of the Gini Vision Library to the specified color.
     
     - note: Screen API only.
     */
    @objc public var backgroundColor = UIColor.black
    
    /**
     Sets custom validations that can be done apart from the default ones (file size, file type...).
     It should throw a `CustomDocumentValidationError` error.
     */
    @objc public var customDocumentValidations: ((GiniVisionDocument) -> CustomDocumentValidationResult) = { _ in
        return CustomDocumentValidationResult.success()
    }
    
    /**
     Sets the font used in the GiniVision library by default.
     */
    
    @objc public lazy var customFont: GiniVisionFont = GiniVisionFont(regular: UIFontPreferred(.regular, andSize: 14),
                                                                bold: UIFontPreferred(.bold, andSize: 14),
                                                                light: UIFontPreferred(.light, andSize: 14),
                                                                thin: UIFontPreferred(.thin, andSize: 14),
                                                                isEnabled: false)
    
    /**
     Can be turned on during development to unlock extra information and to save captured images to camera roll.
     
     - warning: Should never be used outside of a development enviroment.
     */
    @objc public var debugModeOn = false
    
    /**
     Used to handle all the logging messages in order to log them in a different way.
     */
    @objc public var logger: GiniLogger = DefaultLogger()
    
    /**
     Indicates whether the multipage feature is enabled or not. In case of `true`,
     multiple pages can be processed, showing a different review screen when capturing.
     */
    @objc public var multipageEnabled = false
    
    /**
     Sets the tint color of the navigation bar in all screens of the Gini Vision Library to
     the globally specified color or to a default color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarTintColor = UINavigationBar.appearance().barTintColor ?? Colors.Gini.blue
    
    /**
     Sets the tint color of all navigation items in all screens of the Gini Vision Library to
     the globally specified color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarItemTintColor = UINavigationBar.appearance().tintColor
    
    /**
     Sets the font of all navigation items in all screens of the Gini Vision Library to
     the globally specified font or a default font.
     (Deprecated, use `GiniConfiguration.customFont` instead)
     
     - note: Screen API only.
     */
    @objc public var navigationBarItemFont = UIBarButtonItem.appearance()
        .titleTextAttributes(for: .normal)?[NSAttributedStringKey.font.rawValue] as? UIFont ?? UIFontPreferred(.bold,
                                                                                                               andSize: 16)
    
    /**
     Sets the title color in the navigation bar in all screens of the Gini Vision Library to
     the globally specified color or to a default color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarTitleColor = UINavigationBar
        .appearance()
        .titleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor ?? .white
    
    /**
     Sets the title font in the navigation bar in all screens of the Gini Vision Library to
     the globally specified font or to a default font.
     (Deprecated, use `GiniConfiguration.customFont` instead)

     - note: Screen API only.
     */
    @objc public var navigationBarTitleFont = UINavigationBar
        .appearance()
        .titleTextAttributes?[NSAttributedStringKey.font] as? UIFont ?? UIFontPreferred(.regular,
                                                                                 andSize: 16)
    
    /**
     Sets the background color of an informal notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeInformationBackgroundColor = UIColor.black
    
    /**
     Sets the text color of an informal notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeInformationTextColor = UIColor.white
    
    /**
     Sets the background color of an error notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeErrorBackgroundColor = UIColor.red
    
    /**
     Sets the text color of an error notice. Notices are small pieces of
     information appearing underneath the navigation bar.
     */
    @objc public var noticeErrorTextColor = UIColor.white
    
    /**
     Sets the font of all notices. Notices are small pieces of information appearing underneath the navigation bar.
     (Deprecated, use `GiniConfiguration.customFont` instead)

     */
    @objc public var noticeFont = UIFontPreferred(.regular, andSize: 12)
    
    /**
     Indicates whether the open with feature is enabled or not. In case of `true`,
     a new option with the open with tutorial wil be shown in the Help menu
     */
    @objc public var openWithEnabled = false
    
    /**
     Sets the descriptional text when photo library access was denied, advising the
     user to authorize the photo library access in the settings application.
     */
    @objc public var photoLibraryAccessDeniedMessageText =
        NSLocalizedStringPreferred("ginivision.camera.filepicker.photoLibraryAccessDenied",
                                   comment: "This message is shown when Photo library permission is denied")
    
    /**
     Indicates whether the QR Code scanning feature is enabled or not.
     */
    @objc public var qrCodeScanningEnabled = false
    
    /**
     Indicates the status bar style in the Gini Vision Library.
     
     - note: If `UIViewControllerBasedStatusBarAppearance` is set to `false` in the `Info.plist`,
     it may not work in future versions of iOS since the `UIApplication.setStatusBarStyle` method was
     deprecated on iOS 9.0
     */
    @objc public var statusBarStyle = UIStatusBarStyle.lightContent
    
    // MARK: Camera options
    
    /**
     Sets the text for the accessibility label of the capture button which allows
     the user to capture an image of a document.
     
     - note: Used exclusively for accessibility label.
     */
    @objc public var cameraCaptureButtonTitle =
        NSLocalizedStringPreferred("ginivision.camera.captureButton",
                                   comment: "Title for capture button in camera screen will be " +
                                            "used exclusively for accessibility label")
    
    /**
     Sets the descriptional text when camera access was denied, advising the user to
     authorize the camera in the settings application.
     */
    @objc public var cameraNotAuthorizedText =
        NSLocalizedStringPreferred("ginivision.camera.notAuthorized",
                                   comment: "Description text when the camera is not authorized " +
                                            "and the user is advised to change that in the settings app")
    
    /**
     Sets the font of the descriptional text when camera access was denied.
     (Deprecated, use `GiniConfiguration.customFont` instead)
     
     */
    @objc public var cameraNotAuthorizedTextFont = UIFontPreferred(.thin, andSize: 20)
    
    /**
     Sets the text color of the descriptional text when camera access was denied.
     */
    @objc public var cameraNotAuthorizedTextColor = UIColor.white
    
    /**
     Sets the button title when camera access was denied, clicking the button will open the settings application.
     */
    @objc public var cameraNotAuthorizedButtonTitle =
        NSLocalizedStringPreferred("ginivision.camera.notAuthorizedButton",
                                   comment: "Button title to open the settings app")
    
    /**
     Sets the font of the button title when camera access was denied.
     (Deprecated, use `GiniConfiguration.customFont` instead)
     
     */
    @objc public var cameraNotAuthorizedButtonFont = UIFontPreferred(.regular, andSize: 20)
    
    /**
     Sets the text color of the button title when camera access was denied.
     */
    @objc public var cameraNotAuthorizedButtonTitleColor = UIColor.white
    
    /**
     Sets the color of camera preview corner guides
     */
    @objc public var cameraPreviewCornerGuidesColor = UIColor.white
    
    /**
     Sets the message text of a general document validation error, shown in camera screen.
     */
    @objc public var documentValidationErrorGeneral =
        NSLocalizedStringPreferred("ginivision.camera.documentValidationError.general",
                                   comment: "Message text of a general document validation " +
                                            "error shown in camera screen")
    
    /**
     Sets the message text of a document validation error dialog when a file size is higher than 10MB
     */
    @objc public var documentValidationErrorExcedeedFileSize =
        NSLocalizedStringPreferred("ginivision.camera.documentValidationError.excedeedFileSize",
                                   comment: "Message text error shown in camera screen when a file " +
                                            "size is higher than 10MB")
    
    /**
     Sets the message text of a document validation error dialog when a pdf length is higher than 10 pages
     */
    @objc public var documentValidationErrorTooManyPages =
        NSLocalizedStringPreferred("ginivision.camera.documentValidationError.tooManyPages",
                                   comment: "Message text error shown in camera screen when a pdf " +
                                            "length is higher than 10 pages")
    
    /**
     Sets the message text of a document validation error dialog when a file has a
     wrong format (neither PDF, JPEG, GIF, TIFF or PNG)
     */
    @objc public var documentValidationErrorWrongFormat =
        NSLocalizedStringPreferred("ginivision.camera.documentValidationError.wrongFormat",
                                   comment: "Message text error shown in camera screen when a file " +
                                            "has a wrong format (neither PDF, JPEG, GIF, TIFF or PNG)")
    /**
     Set the types supported by the file import feature. `GiniVisionImportFileTypes.none` by default
     
     */
    @objc public var fileImportSupportedTypes: GiniVisionImportFileTypes = .none
    
    /**
     Sets the background color of the new file import button hint
     */
    @objc public var fileImportToolTipBackgroundColor = UIColor.white
    
    /**
     Sets the text color of the new file import button hint
     */
    @objc public var fileImportToolTipTextColor = UIColor.black
    
    /**
     Sets the text color of the new file import button hint
     */
    @objc public var fileImportToolTipCloseButtonColor = Colors.Gini.grey
    
    /**
     Sets the background style when the tooltip is shown
     */
    public var toolTipOpaqueBackgroundStyle: OpaqueViewStyle = .blurred(style: .dark)
    
    /**
     Sets the title text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarCameraTitle =
        NSLocalizedStringPreferred("ginivision.navigationbar.camera.title",
                                   comment: "Title in the navigation bar on the camera screen")
    
    /**
     Sets the text color of the captured images stack indicator label
     */
    @objc public var imagesStackIndicatorLabelTextcolor: UIColor = Colors.Gini.blue
    
    /**
     Sets the close button text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarCameraTitleCloseButton = ""
    
    /**
     Sets the help button text in the navigation bar on the camera screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarCameraTitleHelpButton = ""
    
    /**
     Sets the text color of the QR Code popup button
     */
    @objc public var qrCodePopupButtonColor = Colors.Gini.blue
    
    /**
     Sets the text color of the QR Code popup label
     */
    @objc public var qrCodePopupTextColor = UIColor.black
    
    /**
     Sets the text color of the QR Code popup background
     */
    @objc public var qrCodePopupBackgroundColor = UIColor.white
    
    // MARK: Onboarding options
    /**
     Sets the title text in the navigation bar on the onboarding screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarOnboardingTitle =
        NSLocalizedStringPreferred("ginivision.navigationbar.onboarding.title",
                                   comment: "Title in the navigation bar on the onboarding screen")
    
    /**
     Sets the continue button text in the navigation bar on the onboarding screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarOnboardingTitleContinueButton = ""
    
    /**
     Sets the color of the page controller's page indicator items.
     */
    @objc public var onboardingPageIndicatorColor = UIColor.white.withAlphaComponent(0.2)
    
    /**
     Sets the color of the page controller's current page indicator item.
     */
    @objc public var onboardingCurrentPageIndicatorColor = UIColor.white
    
    /**
     Indicates whether the onboarding screen should be presented at each start of the Gini Vision Library.
     
     - note: Screen API only.
     */
    @objc public var onboardingShowAtLaunch = false
    
    /**
     Indicates whether the onboarding screen should be presented at the first
     start of the Gini Vision Library. It is advised to do so.
     
     - note: Overwrites `onboardingShowAtLaunch` for the first launch.
     - note: Screen API only.
     */
    @objc public var onboardingShowAtFirstLaunch = true
    
    /**
     Sets the text on the first onboarding page.
     */
    @objc public var onboardingFirstPageText =
        NSLocalizedStringPreferred("ginivision.onboarding.firstPage",
                                   comment: "Text on the first page of the onboarding screen")
    
    /**
     Sets the text on the second onboarding page.
     */
    @objc public var onboardingSecondPageText =
        NSLocalizedStringPreferred("ginivision.onboarding.secondPage",
                                   comment: "Text on the second page of the onboarding screen")
    
    /**
     Sets the text on the third onboarding page.
     */
    @objc public var onboardingThirdPageText =
        NSLocalizedStringPreferred("ginivision.onboarding.thirdPage",
                                   comment: "Text on the third page of the onboarding screen")
    
    /**
     Sets the text on the fourth onboarding page. (It is the first on iPad)
     */
    @objc public var onboardingFourthPageText =
        NSLocalizedStringPreferred("ginivision.onboarding.fourthPage",
                                   comment: "Text on the fourth page of the onboarding screen")
    
    /**
     Sets the text on the fifth onboarding page.
     */
    @objc public var onboardingFifthPageText =
        NSLocalizedStringPreferred("ginivision.onboarding.fifthPage",
                                   comment: "Text on the fifth page of the onboarding screen")
    
    /**
     Sets the font of the text for all onboarding pages.
     (Deprecated, use `GiniConfiguration.customFont` instead)

     */
    @objc public var onboardingTextFont = UIFontPreferred(.thin, andSize: 28)
    
    /**
     Sets the color ot the text for all onboarding pages.
     */
    @objc public var onboardingTextColor = UIColor.white
    
    /**
     All onboarding pages which will be presented in a horizontal scroll view to the user.
     By default the Gini Vision Library comes with three pages advising the user to keep the
     document flat, hold the device parallel and capture the whole document.
     
     - note: Any array of views can be passed, but for your convenience we provide the `GINIOnboardingPage` class.
     */
    @objc public var onboardingPages: [UIView] {
        get {
            if let pages = onboardingCustomPages {
                return pages
            }
            guard let page1 = OnboardingPage(imageNamed: "onboardingPage1",
                                             text: onboardingFirstPageText,
                                             rotateImageInLandscape: true),
                let page2 = OnboardingPage(imageNamed: "onboardingPage2",
                                           text: onboardingSecondPageText),
                let page3 = OnboardingPage(imageNamed: "onboardingPage3",
                                           text: onboardingThirdPageText),
                let page4 = OnboardingPage(imageNamed: "onboardingPage5",
                                           text: onboardingFifthPageText) else {
                    return [UIView]()
            }
            
            onboardingCustomPages = [page1, page2, page3, page4]
            if let ipadTipPage = OnboardingPage(imageNamed: "onboardingPage4",
                                                text: onboardingFourthPageText),
                UIDevice.current.isIpad {
                onboardingCustomPages?.insert(ipadTipPage, at: 0)
            }
            return onboardingCustomPages!
        }
        set {
            self.onboardingCustomPages = newValue
        }
    }
    fileprivate var onboardingCustomPages: [UIView]?
    
    // MARK: Review options
    /**
     Sets the title text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitle =
        NSLocalizedStringPreferred("ginivision.navigationbar.review.title",
                                   comment: "Title in the navigation bar on the review screen")
    
    /**
     Sets the back button text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitleBackButton = ""
    
    /**
     Sets the close button text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitleCloseButton = ""
    
    /**
     Sets the continue button text in the navigation bar on the review screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarReviewTitleContinueButton = ""
    
    /**
     Sets the text appearing at the top of the review screen which should ask the user if the
     whole document is in focus and has correct orientation.
     */
    @objc public var reviewTextTop =
        NSLocalizedStringPreferred("ginivision.review.top",
                                   comment: "Text at the top of the review screen asking the user if " +
                                            "the full document is sharp and in the correct orientation")
    
    /**
     The text at the top of the review screen is displayed as a notice and can not be set individually.
     (Deprecated, use `GiniConfiguration.customFont` instead)

     - seeAlso: `noticeFont`
     */
    @objc public var reviewTextTopFont: UIFont {
        return noticeFont
    }
    
    /**
     Sets the text for the accessibility label of the rotate button which allows
     the user to rotate the docuent into reading direction.
     
     - note: Used exclusively for accessibility label.
     */
    @objc public var reviewRotateButtonTitle =
        NSLocalizedStringPreferred("ginivision.review.rotateButton",
                                   comment: "Title for rotate button in review screen will be " +
                                            "used exclusively for accessibility label")
    
    /**
     Sets the text for the accessibility label of the document image view.
     
     - note: Used exclusively for accessibility label.
     */
    @objc public var reviewDocumentImageTitle =
        NSLocalizedStringPreferred("ginivision.review.documentImageTitle",
                                   comment: "Title for document image in review screen will be " +
                                            "used exclusively for accessibility label")
    
    /**
     Sets the background color of the bottom section on the review screen containing the rotation button.
     
     - note: Background will have a 20% transparency, to have enough space for the document image on smaller devices.
     */
    @objc public var reviewBottomViewBackgroundColor = UIColor.black
    
    /**
     Sets the text appearing at the bottom of the review screen which should encourage
     the user to check sharpness by double-tapping the image.
     (Deprecated, use `GiniConfiguration.customFont` instead)

     */
    @objc public var reviewTextBottom =
        NSLocalizedStringPreferred("ginivision.review.bottom",
                                   comment: "Text at the bottom of the review screen encouraging the " +
                                            "user to check sharpness by double-tapping the image")
    
    /**
     Sets the font of the text appearing at the bottom of the review screen.
     */
    @objc public var reviewTextBottomFont = UIFontPreferred(.thin, andSize: 12)
    
    /**
     Sets the color of the text appearing at the bottom of the review screen.
     */
    @objc public var reviewTextBottomColor = UIColor.white
    
    // MARK: Multipage options
    
    /**
     Sets the color of the pages container and toolbar
     */
    @objc public var multipagePagesContainerAndToolBarColor = Colors.Gini.pearl
    
    /**
     Sets the tint color of the toolbar items
     */
    @objc public var multipageToolbarItemsColor = Colors.Gini.blue
    
    /**
     Sets the tint color of the page indicator
     */
    @objc public var multipagePageIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the tint color of the page background
     */
    @objc public var multipagePageBackgroundColor = Colors.Gini.blue
    
    // MARK: Analysis options
    
    /**
     Sets the color of the loading indicator on the analysis screen to the specified color.
     */
    @objc public var analysisLoadingIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the text of the loading indicator on the analysis screen to the specified text.
     */
    @objc public var analysisLoadingText =
        NSLocalizedStringPreferred("ginivision.analysis.loadingText",
                                   comment: "Text appearing at the center of the analysis screen " +
                                            "indicating that the document is being analysed")
    
    /**
     Sets the color of the PDF information view on the analysis screen to the specified color.
     */
    @objc public var analysisPDFInformationBackgroundColor = Colors.Gini.bluishGreen
    
    /**
     Sets the color of the PDF information view on the analysis screen to the specified color.
     */
    @objc public var analysisPDFInformationTextColor = UIColor.white
    
    /**
     Sets the text appearing at the top of the analysis screen indicating pdf number of pages
     */
    @objc public func analysisPDFNumberOfPages(pagesCount count: Int) -> String {
        return NSLocalizedStringPreferred("ginivision.analysis.pdfpages",
                                          comment: "Text appearing at the top of the analysis " +
                                                    "screen indicating pdf number of pages",
                                          args: count)
    }
    
    /**
     Sets the title text in the navigation bar on the analysis screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarAnalysisTitle =
        NSLocalizedStringPreferred("ginivision.navigationbar.analysis.title",
                                   comment: "Title in the navigation bar on the analysis screen")
    
    /**
     Sets the back button text in the navigation bar on the analysis screen.
     */
    @objc public var navigationBarAnalysisTitleBackButton = ""
    
    // MARK: Help screens
    
    /**
     Sets the back button text in the navigation bar on the help menu screen.
     */
    @objc public var navigationBarHelpMenuTitleBackToCameraButton = ""
    
    /**
     Sets the back button text in the navigation bar on the help screen.
     */
    @objc public var navigationBarHelpScreenTitleBackToMenuButton = ""
    
    // MARK: Supported formats
    
    /**
     Sets the color of the unsupported formats icon background to the specified color.
     */
    @objc public var nonSupportedFormatsIconColor = Colors.Gini.crimson
    
    /**
     Sets the color of the supported formats icon background to the specified color.
     */
    @objc public var supportedFormatsIconColor = Colors.Gini.paleGreen
    
    // MARK: Open with tutorial options
    
    /**
     Sets the text of the app name for the Open with tutorial texts
     
     */
    @objc public var openWithAppNameForTexts = Bundle.main.appName
    
    /**
     Sets the color of the step indicator for the Open with tutorial
     
     */
    @objc public var stepIndicatorColor = Colors.Gini.blue
    
    // MARK: No results options
    
    /**
     Sets the color of the bottom button to the specified color
     */
    @objc public var noResultsBottomButtonColor = Colors.Gini.blue
    
    /**
     Sets the color of the warning container background to the specified color
     */
    @objc public var noResultsWarningContainerIconColor = Colors.Gini.rose
}
