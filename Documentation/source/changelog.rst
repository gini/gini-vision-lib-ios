=========
Changelog
=========

3.0.3-beta (2017-02-01)
==================

- Added support for landscape mode in CameraViewController.
- Removed The `GINI` prefix from library classes.

3.0.2-beta (2017-01-19)
==================

Swift 3 support.

- Project language conversion to Swift 3

2.3.3-beta (2017-02-01)
==================

- Added support for landscape mode in GINICameraViewController

2.3.2-beta (2017-01-19)
==================

Swift 2.3 support.

- Project language conversion to Swift 2.3

2.0.3 (2017-02-01)
==================

- Added support for landscape mode in GINICameraViewController

2.0.2 (2017-01-10)
==================

Minor non-breaking changes to the API.

- `cameraOverlay` in GINICameraViewController made public.
- `scrollView` in GINIOnboardingViewController made public.
- Minor update to license file, not changing the essential meaning of the license.
- Fixes a problem where images would not be compressed after rotation.


2.0.0 (2016-08-25)
==================

Major version of the completely rewritten Gini Vision Library for iOS.

- Using the Screen API a picture can be taken and analyzed with an easy to present modal view. Implement the `GINIVisionDelegat` to get informed about the current status of the Gini Vision Library and to guide the user through the analysis process.
- Using the Component API a picture can be taken and analyzed by implementing the different component view controllers for camera, onboarding, review and analysis. You can provide your own navigation elements arround the Gini Vision components.
- Consult the example apps (Objective-C or Swift) for details on how to use the Gini Vision Library for iOS.


2.0.0-stub.3 (2016-07-19)
=========================

- Adds a complete Objectice-C integration example.


2.0.0-stub.2 (2016-07-15)
=========================

- Stub version of the completely rewritten Gini Vision Library using Swift.
- Provides two integration options: 1) A Screen API ​that can easily be implemented. 2) A more complex ​but at the same time​ more flexible Component API. Both APIs are ​easy to configure by using ​the `GINIConfiguration` object.
- For ​the​ communication between your app and the Library use the `GINIVisionDelegate` for the Screen API or pass according closures/blocks when using the Component API.
- This stub release implements all calls for the future 2.0.0 release. It allows ​the​ user to capture a document and review it. Also screens for onboarding and further analysis are provided. ​For​ the final release the UI will be further improved and minor changes are made ​in​ the implementations ​if really necessary​.
