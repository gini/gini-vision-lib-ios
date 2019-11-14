Changelog
=========
5.0.8 (2019-11-14)
------------------
-  Defer asking for camera permission until after the onboarding is complete.

5.0.7 (2019-10-31)
------------------
-   Reduced memory usage by the Gallery.

4.8.8 (2019-10-30)
------------------
-   Reduced memory usage by the Gallery.

5.0.6 (2019-10-25)
------------------
-   Updated the Gini library to v. 0.2.0

5.0.5 (2019-10-23)
------------------
-   Don't require the client to retain the GiniVision view controller for the feedback closure to run correctly.

5.0.4 (2019-10-22)
------------------
-   Fixed a problem where the lack of camera permissions screen isn't shown directly following the user refusing to grant the camera permissions.

5.0.3 (2019-10-17)
------------------
-   Made GiniVisionResultsDelegate accessible from Objective-C again.

5.0.2 (2019-10-16)
------------------
-   Support for Dark Mode.

5.0.1 (2019-10-09)
------------------

-   Removed a trailing space from "No results " folder name.

5.0.0 (2019-05-22)
------------------

-   Added the new API SDK in the network plugin.
-   Removed support for iOS 9.0.
-   Removed support for Obj-C in the networking plugin.
-   Added document validation for empty files.

4.8.6 (2019-10-09)
------------------

- Removed a trailing space from the "No Results " folder name.

4.8.5 (2019-10-02)
------------------

- Fixed Swift 4 builds and builds against iOS 12 SDK

4.8.4 (2019-09-25)
------------------

- Fixed scanning of EPC06912 with character sets other than 1 or 2.
- Fixed truncated text in the Help section.

4.8.3 (2019-09-09)
------------------

- Support for iOS 13:
  - Light mode only: when using dark mode GVL's UI remains in light mode.
  - Fixed QR Code rendering on the QR Code detected popup.

4.8.2 (2019-07-05)
------------------

- Fixed a crash that could occur when opening and closing the multipage review screen multiple times.

4.8.1 (2019-06-28)
------------------

-   Fixed a crash when using the Networking module and the results delegate is deallocated before analysis finishes.
-   Fixed the Objective-C example.
-   AnalysisResult properties made available to Objective-C.

4.8.0 (2019-05-07)
------------------

-   Added the option to set the flash off by default with the `GiniConfiguration.flashOnByDefault` flag.
-   Improved navigation to the help screens.

4.7.2 (2019-05-03)
------------------

-   Renamed EPS QR Code url extraction name to `epsPaymentQRCodeUrl`, which is returned in the 
    `GiniVisionResultsDelegate.giniVisionAnalysisDidFinishWith(result:sendFeedbackBlock:)` 
    method when using the Networking plugin.
    If not, a `GiniQRCodeDocument` will be returned directly in the `GiniVisionDelegate.didCapture(document:networkDelegate:)` method.

4.7.1 (2019-04-17)
------------------

-   Fixed navigation bar appearance issue after opening a document from the file browser.

4.7.0 (2019-04-15)
------------------

-   Added EPS QR code detection support.
-   Added client credential deletion possibility in the Networking plugin.

4.6.0 (2019-04-05)
------------------

-   Added haptic feedback for image capturing.
-   Added images to `GiniVisionResultsDelegate` results method (breaking change).
-   Fixed breaking constraints issue.
-   Fixed issue with tooltip position in camera screen.

4.5.0 (2019-02-28)
------------------

-   Added flash toggle in the camera screen, configurable via `GiniConfiguration.flashToggleEnabled`.

4.4.1 (2019-02-20)
------------------

-   Fixed issue with Onboarding modal transition style.

4.4.0 (2019-02-13)
------------------

-   Fixed issue with latest versions of Cocoapods.
-   Added flag for Supported formats screen (`GiniConfiguration.shouldShowSupportedFormatsScreen`)

4.3.2 (2019-02-04)
------------------

-   Fixed issue with non exposed ObjC members.

4.3.1 (2019-01-29)
------------------

-   Added customizable tint color for navigation bar in Document explorer

4.3.0 (2019-01-28)
------------------

-   Added English support
-   Added Dynamic font support for iOS > 10.0

4.2.0 (2019-01-16)
------------------

-   Added the possibility to use the accounting API
    if using the Networking module
-   Improved memory management when using the multipage feature
-   Improved performance when fetching images from gallery
-   Fixed issue with button state in gallery

4.1.0 (2018-10-31)
------------------

-   Added the possibility to add metadata information when uploading documents
    if using the Networking module

4.0.2 (2018-10-23)
------------------

-   Fixed issue with _Open_ button text color in `ImagePickerViewController`
-   Fixed issue with the _Podfile_ in the Example app

4.0.1 (2018-09-12)
------------------

-   Fixed layout issue in iOS 12

4.0.0 (2018-07-09)
------------------

-   Added multipage mode
-   Added network plugin
-   Minor UX/UI improvements
-   Added customization guide

3.3.5 (2018-07-06)
------------------

-   Added a flag for the Drag&Drop step in "Open with" tutorial (via the `GiniConfiguration.shouldShowDragAndDropTutorial` property).

3.3.4 (2018-06-13)
------------------

-   Added customizable opaque background view style when the tool tip is shown (via the `GiniConfiguration.toolTipOpaqueBackgroundStyle` property).

3.3.3 (2018-06-01)
------------------

-   Fixed issue with Next button when using VoiceOver in the Onboarding screen.

3.3.2 (2018-03-08)
------------------

-   Fixed issue with status bar when both Gallery and document picker were shown.
-   Fixed back arrows in help screens, matching the one shown in the Review screen.
-   Fixed issue when using debug mode in the simulator and trying to capture the default image.

3.3.1 (2018-01-24)
------------------

-   Fixed issue with camera orientation when it appears for the first time
    and the device was in landscape orientation (only iPad).
-   Fixed issue with Gallery permissions on iOS 9.

3.3.0 (2018-01-22)
------------------

-   Added QR code scanning in camera screen (final).

3.2.3 (2018-01-17)
------------------

-   Fixed enum visibility, custom document validations closure and
    custom font property on GiniConfiguration (for Objective C projects).

3.3.0-beta (2017-12-08)
------------------

-   Added QR Code scanning in camera screen (beta)

3.2.2 (2017-11-27)
------------------

-   Adapted UI for iPhone X
-   Fixed double tap issue on Review screen

3.2.1 (2017-11-15)
------------------

-   Fixed access control on help menu screen view controller initializer.
-   Fixed minor bugs.

3.2.0 (2017-10-27)
------------------

-   New help screens

3.2.0-rc.1 (2017-10-11)
------------------

-   Added file import support (both for PDFs and Images).
-   Added _Open with_ support.
-   New design for Camera and Analysis screens.
-   Added Drag and Drop on iPad (iOS 11) for file import from Camera Screen.

3.1.0 (2017-08-28)
------------------

-   Adapted UI for iPad (landscape orientation is now supported on iPad)
-   Fixed issue on preview screen, when there is no orientation (device in flat position)
-   For iPhones we disabled automatic rotation of the picture in the preview view. Previously it was rotated when the device was held in landscape. Now the picture is always shown in portrait orientation on iPhones.

3.0.5 (2017-05-12)
------------------

-   Adjusted the default JPEG compression level
-   Improved JPEG generation and EXIF metadata creation
-   Fixed bug related to image compression

3.0.4 (2017-03-23)
------------------

-   Fixed not being able to set custom titles on buttons
-   Added additional tags to the EXIF UserComment field to identify original and rotated images

3.0.3 (2017-02-28)
------------------

-   Added support for landscape mode in CameraViewController.
-   Removed The GINI prefix from library classes.

3.0.2-beta (2017-01-19)
------------------

Swift 3 support.

-   Project language conversion to Swift 3

2.3.3-beta (2017-02-01)
------------------

-   Added support for landscape mode in GINICameraViewController

2.3.2-beta (2017-01-19)
------------------


Swift 2.3 support.

-   Project language conversion to Swift 2.3

2.0.3 (2017-02-01)
------------------

-   Added support for landscape mode in GINICameraViewController

2.0.2 (2017-01-10)
------------------

Minor non-breaking changes to the API.

-   cameraOverlay in GINICameraViewController made public.
-   scrollView in GINIOnboardingViewController made public.
-   Minor update to license file, not changing the essential meaning of the license.
-   Fixes a problem where images would not be compressed after rotation.

2.0.0 (2016-08-25)
------------------

Major version of the completely rewritten Gini Vision Library for iOS.

-   Using the Screen API a picture can be taken and analyzed with an easy to present modal view. Implement the GINIVisionDelegat to get informed about the current status of the Gini Vision Library and to guide the user through the analysis process.
-   Using the Component API a picture can be taken and analyzed by implementing the different component view controllers for camera, onboarding, review and analysis. You can provide your own navigation elements arround the Gini Vision components.
-   Consult the example apps (Objective-C or Swift) for details on how to use the Gini Vision Library for iOS.

2.0.0-stub.3 (2016-07-19)
-------------------------

-   Adds a complete Objective-C integration example.

2.0.0-stub.2 (2016-07-15)
-------------------------

-   Stub version of the completely rewritten Gini Vision Library using Swift.
-   Provides two integration options: 1) A Screen API ​that can easily be implemented. 2) A more complex ​but at the same time​ more flexible Component API. Both APIs are ​easy to configure by using ​the GINIConfiguration object.
-   For ​the​ communication between your app and the Library use the \`GINIVisionD
