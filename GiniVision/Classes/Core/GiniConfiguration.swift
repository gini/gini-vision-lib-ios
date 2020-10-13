//
//  GiniConfiguration.swift
//  GiniVision
//
//  Created by Peter Pult on 15/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

@objc public class GiniColor : NSObject {
    var lightModeColor: UIColor
    var darkModeColor: UIColor
    
    init(lightModeColor: UIColor, darkModeColor: UIColor) {
        self.lightModeColor = lightModeColor
        self.darkModeColor = darkModeColor
    }
}

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
    static var shared = GiniConfiguration()
    
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
    @available(*, unavailable,
    message: "Use the screen specific background color instead e.g. onboardingScreenBackgroundColor")
    @objc public var backgroundColor: UIColor = UIColor.black
    
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
    
    @objc public lazy var customFont: GiniVisionFont = GiniVisionFont(regular: UIFont.systemFont(ofSize: 14,
                                                                                                 weight: .regular),
                                                                      bold: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .bold),
                                                                      light: UIFont.systemFont(ofSize: 14,
                                                                                               weight: .light),
                                                                      thin: UIFont.systemFont(ofSize: 14,
                                                                                              weight: .thin),
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
     
     - note: Screen API only.
     */
    @objc public var navigationBarItemFont = UIBarButtonItem.appearance()
        .titleTextAttributes(for: .normal).dictionary?[NSAttributedString.Key.font.rawValue] as? UIFont ??
        UIFont.systemFont(ofSize: 16, weight: .bold)
    
    /**
     Sets the title color in the navigation bar in all screens of the Gini Vision Library to
     the globally specified color or to a default color.
     
     - note: Screen API only.
     */
    @objc public var navigationBarTitleColor = UINavigationBar
        .appearance()
        .titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor ?? .white
    
    /**
     Sets the title font in the navigation bar in all screens of the Gini Vision Library to
     the globally specified font or to a default font.

     - note: Screen API only.
     */
    @objc public var navigationBarTitleFont = UINavigationBar
        .appearance()
        .titleTextAttributes?[NSAttributedString.Key.font] as? UIFont ?? UIFont.systemFont(ofSize: 16, weight: .regular)
    
    /**
     Sets the tint color of the UIDocumentPickerViewController navigation bar.
     
     - note: Use only if you have a custom `UIAppearance` for your UINavigationBar
     - note: Only iOS >= 11.0
     */
    @objc public var documentPickerNavigationBarTintColor: UIColor?
    
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
     Indicates whether the open with feature is enabled or not. In case of `true`,
     a new option with the open with tutorial wil be shown in the Help menu
     */
    @objc public var openWithEnabled = false
    
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
     Sets the text color of the descriptional text when camera access was denied.
     */
    @objc public var cameraNotAuthorizedTextColor = UIColor.white
    
    /**
     Sets the text color of the button title when camera access was denied.
     */
    @objc public var cameraNotAuthorizedButtonTitleColor = UIColor.white
    
    /**
     Sets the color of camera preview corner guides
     */
    @objc public var cameraPreviewCornerGuidesColor = UIColor.white
    
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
    public var toolTipOpaqueBackgroundStyle: OpaqueViewStyle {
        
        set {
            _toolTipOpaqueBackgroundStyle = newValue
        }
        
        get {
            
            if let setValue = _toolTipOpaqueBackgroundStyle {
                return setValue
            } else {
                
                if #available(iOS 13.0, *) {
                    return .blurred(style: .regular)
                } else {
                    return .blurred(style: .dark)
                }
            }
        }
    }
    
    private var _toolTipOpaqueBackgroundStyle: OpaqueViewStyle?
    
    /**
     Sets the text color of the item selected background check
     */
    @objc public var galleryPickerItemSelectedBackgroundCheckColor = Colors.Gini.blue
    
    /**
     Sets the background color for gallery screen.
     */
    
    @objc public var galleryScreenBackgroundColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
    
    /**
     Indicates whether the flash toggle should be shown in the camera screen.
     
     */
    @objc public var flashToggleEnabled = false
    
    /**
     When the flash toggle is enabled, this flag indicates if the flash is on by default.
     */
    @objc public var flashOnByDefault = true
    
    /**
     Sets the color of the captured images stack indicator label
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
    @objc public var qrCodePopupTextColor = GiniColor(lightModeColor: .black, darkModeColor: .white)
    
    /**
     Sets the text color of the QR Code popup background
     */
    @objc public var qrCodePopupBackgroundColor = GiniColor(lightModeColor: .white, darkModeColor: UIColor.fromHexColor(0x1c1c1eff))
    
    // MARK: Onboarding screens

    /**
     Sets the continue button text in the navigation bar on the onboarding screen.
     
     - note: Screen API only.
     */
    @objc public var navigationBarOnboardingTitleContinueButton = ""
    
    /**
     Sets the color of the page controller's page indicator items.
     */
    @objc public var onboardingPageIndicatorColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the color of the page controller's current page indicator item.
     */
    @objc public var onboardingCurrentPageIndicatorColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
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
     Sets the color ot the text for all onboarding pages.
     */
    @objc public var onboardingTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
    
    /**
     Sets the background color for all onboarding pages.
     */
        
    @objc public var onboardingScreenBackgroundColor = GiniColor(lightModeColor: .black, darkModeColor: .black)
    
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
                                             text: .localized(resource: OnboardingStrings.onboardingFirstPageText),
                                             rotateImageInLandscape: true),
                let page2 = OnboardingPage(imageNamed: "onboardingPage2",
                                           text: .localized(resource: OnboardingStrings.onboardingSecondPageText)),
                let page3 = OnboardingPage(imageNamed: "onboardingPage3",
                                           text: .localized(resource: OnboardingStrings.onboardingThirdPageText)),
                let page4 = OnboardingPage(imageNamed: "onboardingPage5",
                                           text: .localized(resource: OnboardingStrings.onboardingFifthPageText)) else {
                    return [UIView]()
            }
            
            onboardingCustomPages = [page1, page2, page3, page4]
            if let ipadTipPage = OnboardingPage(imageNamed: "onboardingPage4",
                                                text: .localized(resource: OnboardingStrings.onboardingFourthPageText)),
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
     Sets the background color of the bottom section on the review screen containing the rotation button.
     
     - note: Background will have a 20% transparency, to have enough space for the document image on smaller devices.
     */
    @objc public var reviewBottomViewBackgroundColor = UIColor.black
    
    /**
     Sets the font of the text appearing at the bottom of the review screen.
     */
    @objc public var reviewTextBottomFont = UIFont.systemFont(ofSize: 12, weight: .thin)
    
    /**
     Sets the color of the text appearing at the bottom of the review screen.
     */
    @objc public var reviewTextBottomColor = UIColor.white
    
    // MARK: Multipage options
    
    /**
     Sets the color of the pages container and toolbar
     */
    @objc public var multipagePagesContainerAndToolBarColor = GiniColor(lightModeColor: Colors.Gini.pearl, darkModeColor: UIColor.fromHexColor(0x1C1C1C))
    
    @objc private var _multipagePagesContainerAndToolBarColor: UIColor?
    
    @objc public var indicatorCircleColor = GiniColor(lightModeColor: Colors.Gini.pearl, darkModeColor: .lightGray)
    
    /**
     Sets the tint color of the toolbar items
     */
    @objc public var multipageToolbarItemsColor = Colors.Gini.blue
    
    /**
     Sets the tint color of the page indicator
     */
    @objc public var multipagePageIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the background color of the page selected indicator
     */
    @objc public var multipagePageSelectedIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the background color of the page background
     */
    @objc public var multipagePageBackgroundColor = GiniColor(lightModeColor: .white, darkModeColor: UIColor.fromHexColor(0x1c1c1eff))
    
    @objc private var _multipagePageBackgroundColor: UIColor?
    
    /**
     Sets the tint color of the draggable icon in the page collection cell
     */
    @objc public var multipageDraggableIconColor = Colors.Gini.veryLightGray

    /**
     Sets the background style when the tooltip is shown in the multipage screen
     */
    public var multipageToolTipOpaqueBackgroundStyle: OpaqueViewStyle = .blurred(style: .light)
    
    // MARK: Analysis options
    
    /**
     Sets the color of the loading indicator on the analysis screen to the specified color.
     */
    @objc public var analysisLoadingIndicatorColor = Colors.Gini.blue
    
    /**
     Sets the color of the PDF information view on the analysis screen to the specified color.
     */
    @objc public var analysisPDFInformationBackgroundColor = Colors.Gini.bluishGreen
    
    /**
     Sets the color of the PDF information view on the analysis screen to the specified color.
     */
    @objc public var analysisPDFInformationTextColor = UIColor.white
    
    /**
     Sets the back button text in the navigation bar on the analysis screen.
     */
    @objc public var navigationBarAnalysisTitleBackButton = ""
    
    // MARK: Help screens
    
    /**
     Sets the background color for all help screens.
     */
    
    @objc public var helpScreenBackgroundColor =  GiniColor(lightModeColor: .black, darkModeColor: .black)
    
    /**
     Sets the back button text in the navigation bar on the help menu screen.
     */
    @objc public var navigationBarHelpMenuTitleBackToCameraButton = ""
    
    /**
     Sets the back button text in the navigation bar on the help screen.
     */
    @objc public var navigationBarHelpScreenTitleBackToMenuButton = ""
    
    /**
     Indicates whether the supported format screens should be shown. In case of `false`,
     the option won't be shown in the Help menu.
     */
    @objc public var shouldShowSupportedFormatsScreen = true
    
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
    
    /**
     Sets if the Drag&Drop step should be shown in the "Open with" tutorial
     */
    @objc public var shouldShowDragAndDropTutorial = true
    
    // Undocumented--Xamarin only
    @objc public var closeButtonResource: PreferredButtonResource?
    @objc public var helpButtonResource: PreferredButtonResource?
    @objc public var backToCameraButtonResource: PreferredButtonResource?
    @objc public var backToMenuButtonResource: PreferredButtonResource?
    @objc public var nextButtonResource: PreferredButtonResource?
    @objc public var cancelButtonResource: PreferredButtonResource?
}
