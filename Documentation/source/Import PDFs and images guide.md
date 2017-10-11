Import PDFs and images
=============================


If you want to add _File import_ feature on your app, first you need to specify the supported types (`fileImportSupportedTypes `) on the `GiniConfiguration` instance.

```swift
let giniConfiguration = GiniConfiguration()
giniConfiguration.fileImportSupportedTypes = .pdf_and_images
```

These are the file import supported type cases: 

* `pdf`
* `pdf_and_images`
* `none` (In case you want to diable _File import funcionality_, being the _default_ value).

Also if you want to add some custom validations for the imported `GiniVisionDocument`
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 5 * 1024 * 1024
            if document.data.count > maxFileSize {
                throw DocumentValidationError.custom(message: "Diese Datei ist leider größer als 5MB")
            }
        }

Import images from camera roll
----------------------

In case that you want to enable your app to import images from **Photo Gallery** and also support **iOS 10** you need to specify the `NSPhotoLibraryUsageDescription ` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when accessing the **Photo Gallery**.
 
Import images and PDFs from other apps
------------------------------------

In order to enable your app to import PDFs and images from other apps like *Dropbox*, *iCloud* or *Drive*, you need to enable _iCloud document support_ in your app.

<center><img src="https://imgur.com/download/mLY9Bf8" border="1"/></center>

For more information take a look at [Incorporating iCloud into Your App](https://developer.apple.com/library/content/documentation/General/Conceptual/iCloudDesignGuide/Chapters/Introduction.html#//apple_ref/doc/uid/TP40012094) guide from _Apple documentation_.
