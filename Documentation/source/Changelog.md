Changelog
=========

4.0.0-beta.1 (2018-05-15)
------------------

-   Added multipage mode
-   Added network plugin
-   Minor UX/UI improvements 

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
