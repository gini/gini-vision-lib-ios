Updating to 4.0
=============================

## What's new?
---

### Multi-page support
Documents with multiple pages are now supported, being possible to capture several pages to get the analysis results. To enable it (disabled by default) set the `GiniConfiguration.multipageEnabled` property to `true`.
Besides, when using the Component API, the `MultipageReviewViewController` component is used to handle one or several documents (see the Example app for implementation details).

### Networking implementation
The Screen API now offers the option to include all the networking analysis logic, only being necessary to provide a `GiniVisionResultsDelegate` when initializing the Screen API in order to get the analysis results.
If you want to migrate your Screen API implementation to this one, just remove your current implementation of the `GiniVisionDelegate` and implement the `GiniVisionResultsDelegate`. You have had to add the additional line in your `Podfile` before, as pointed out in the [Integration guide](integration.html).

### Custom photos gallery
A custom photos gallery picker has been designed, which unlike the native `UIImagePickerController` allows to select multiple photos at the same time, to start caching before showing it (no delays when showing the first time) and some additional customization.

### Gini iOS SDK 1.0

In order to use the new Multipage feature you have to update the [Gini iOS SDK](https://github.com/gini/gini-sdk-ios) to version 1.0, which uses a different way of handling the document analysis, introducing **Partial** and **Composite** documents.

#### Bolts
In order to use the new Multipage feature, you have to update the [Gini iOS SDK](https://github.com/gini/gini-sdk-ios) to version 1.0 which uses last version of _Bolts_ (1.9). This version introduces a lot of improvements and bug fixes, but also some breaking changes in the syntaxis.
* `continue()` is now `continueWith(block:)`
* `continue(successBlock:)` is now `continueOnSuccessWith(block:)`
* And now every `BFTask` has a specific type for the result, `BFTask<ResultType>`. i.e: `BFTask<GINIDocument>`


## Breaking Changes
---

### Only Screen API
#### GiniVisionDelegate

* `GiniVisionDelegate.didCapture(_:)` and `GiniVisionDelegate.didCapture(document:)` are replaced with `GiniVisionDelegate.didCapture(document:networkDelegate:)`.
* `GiniVisionDelegate.didReview(_:withChanges:)` and `GiniVisionDelegate.didReview(document:withChanges:)` are replaced by `GiniVisionDelegate.didReview(documents:networkDelegate:)`.
* `GiniVisionDelegate.didCancelReview()` is replaced by `GiniVisionDelegate.didCancelReview(for:)`.
* `GiniVisionDelegate.didShowAnalysis(_:)` is not used anymore.

### Only Component API

This version adds new screens and new features to old screens, adding also
more complexity to them. That is why now every screen of the Gini Vision Library has a `delegate` to handle every interaction from the outside, making the communication with it more extensible and clearer.

#### Camera screen
* To improve the navigation between screens, the file import pickers has been decoupled from the `CameraViewController` and they are now handled by a `DocumentPickerCoordinator`. For now on, you have to use the `CameraViewController.init(giniConfiguration:)` initializer and set the `CameraViewControllerDelegate` to get the selected picker in the `CameraViewControllerDelegate.camera(_:didSelect:)` method.
* Now document validation should be handled outside of the `CameraViewController`. 
* To enable _Drag&Drop_, just call the `DocumentPickerCoordinator.setupDragAndDrop(in:)` method, passing the view that will handle the drop interaction (we recommend to pass the `CameraViewController.view`).
* With the addition of a custom image picker to support multiple selection, you can start caching the album images by calling the `DocumentPickerCoordinator.startCaching()` method when creating the coordinator, but only if the gallery access permission is granted before (`DocumentPickerCoordinator.isGalleryPermissionGranted`).
