Updating to 4.0
=============================

## Breaking Changes


### Bolts
In order to use the new Multipage feature, you have to update the [Gini iOS SDK](https://github.com/gini/gini-sdk-ios) to version 1.0 which uses last _Bolts_ version (1.9). This version introduces a lot of improvements and bug fixes, but also some breaking changes in the syntaxis.
* `continue()` is now `continueWith(block:)`
* `continue(successBlock:)` is now `continueOnSuccessWith(block:)`
* And now every `BFTask` has a specific type for the result, `BFTask<ResultType>`. i.e: `BFTask<GINIDocument>`

### Only Screen API
#### GiniVisionDelegate

* `GiniVisionDelegate.didCapture(_:)` and `GiniVisionDelegate.didCapture(document:)` are replaced with `GiniVisionDelegate.didCapture(document:uploadDelegate:)`
* `GiniVisionDelegate.didReview(_:withChanges:)` and `GiniVisionDelegate.didReview(document:withChanges:)` are replaced by `GiniVisionDelegate.didReview(documents:)`
* `GiniVisionDelegate.didCancelReview()` is replaced by `GiniVisionDelegate.didCancelReview(for:)``

### Only Component API

This version adds new screens and new features to old screens, adding
more complexity to them. That is why now every screen of the Gini Vision Library has a `delegate` to handle every interaction from the outside, making the communication with it more extensible and clearer.

#### Camera screen
* To improve the navigation between screens, the file import pickers has been decoupled from the `CameraViewController` and they are now handled by a `DocumentPickerCoordinator`.
In case that you want to use both pickers, you have to use the `CameraViewController.init(giniConfiguration:)` initializer and set the `CameraViewControllerDelegate` to get the selected picker in the `CameraViewControllerDelegate.camera(_:didSelect:)` method.
* Now document validation should be handled outside of the `CameraViewController`. After capturing and validating a `GiniQRCodeDocument`, you can show the QR Code popup with the `CameraViewController.showPopup(forQRDetected:didTapDone:)` method.
* To enable _Drag&Drop_ just call the `DocumentPickerCoordinator.setupDragAndDrop(in:)` method, passing the view that will handle the drop interaction (we recommend to pass the `CameraViewController.view`).
* Since it has been introduce a custom image picker to support multiple selection, you can start caching the album images calling the `DocumentPickerCoordinator.startCaching()` method when creating the coordinator and only if the gallery access permission is granted before (`DocumentPickerCoordinator.isGalleryPermissionGranted`).
