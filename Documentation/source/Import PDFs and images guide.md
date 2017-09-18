Import PDFs and images
=============================

Import images from camera roll
----------------------

In case that you want to enable your app to import images from **Photo Gallery** and also support **iOS 10** you need to specify the `NSPhotoLibraryUsageDescription ` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when accessing the **Photo Gallery**.
 
Import images and PDFs from other apps
------------------------------------

In order to enable your app to import PDFs and images from other apps like *Dropbox*, *iCloud* or *Drive*, you need to enable _iCloud document support_ in your app.


### Documentation

-   [Incorporating iCloud into Your App](https://developer.apple.com/library/content/documentation/General/Conceptual/iCloudDesignGuide/Chapters/Introduction.html#//apple_ref/doc/uid/TP40012094) from _Apple documentation_.