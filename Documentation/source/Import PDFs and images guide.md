Import PDFs and images
=============================


If you want to add the _File import_ feature on your app, first you need to specify the supported types (`fileImportSupportedTypes `) on the `GiniConfiguration` instance.

```swift
let giniConfiguration = GiniConfiguration()
giniConfiguration.fileImportSupportedTypes = .pdf_and_images
```

These are the cases for file import supported file types:

* `pdf`
* `pdf_and_images`
* `none` (In case you want to disable _File import_ funcionality, including UI related. This is the _default_ value).

Also if you want to add some custom validations for the imported `GiniVisionDocument`, you can specify them in the `GiniConfiguration` closure, `customDocumentValidations`. Here is an example:

```swift
giniConfiguration.customDocumentValidations = { document in
	// As an example of custom document validation, we add a more strict check for file size
	let maxFileSize = 5 * 1024 * 1024 // 5MB
	if document.data.count > maxFileSize {
		throw DocumentValidationError.custom(message: "Diese Datei ist leider größer als 5MB")
	}
}
```
#### Only Component API

Additionaly - when using the Component API - you have to use the `DocumentPickerCoordinator` to present both the Photo Gallery and the File Explorer and to handle all the interaction with them.
To enable _Drag&Drop_, just call the `DocumentPickerCoordinator.setupDragAndDrop(in:)` method, passing the view that will handle the drop interaction (we recommend to pass the `CameraViewController.view`).

Also, with the addition of a custom image picker to support multiple selection, you can start caching the album images by calling the `DocumentPickerCoordinator.startCaching()` method when creating the coordinator, but only if the gallery access permission is granted before (`DocumentPickerCoordinator.isGalleryPermissionGranted`).


Import images from camera roll
----------------------

To enable your app to import images from **Photo Gallery** and also support **iOS 10** you need to specify the `NSPhotoLibraryUsageDescription ` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when accessing the **Photo Gallery**.

Import images and PDFs from other apps
------------------------------------

In order to enable your app to import PDFs and images from other apps like *Dropbox*, *iCloud* or *Drive*, you need to enable _iCloud document support_ in your app.

<center><img src="img/icloud_capabilities.png" border="1"/></center>

For more information take a look at [Incorporating iCloud into Your App](https://developer.apple.com/library/content/documentation/General/Conceptual/iCloudDesignGuide/Chapters/Introduction.html#//apple_ref/doc/uid/TP40012094) guide from _Apple documentation_.
