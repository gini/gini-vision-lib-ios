Enable your app to open PDFs and Images
=============================

General considerations
----------------------

Enabling your app to open PDFs and images allows your users to open any kind of files which are identified by the OS as PDFs or images. Make sure to check the MIME type and that the file size is below an acceptable threshold (5MB for example). It is also advisable to check the first bytes of the incoming files to determine their type and allow only PDFs and known image types.

Registering PDF and image file types
------------------------------------

Add the following to your `Info.plist`:

``` sourceCode
<key>CFBundleDocumentTypes</key>
<array>
        <dict>
            <key>CFBundleTypeIconFiles</key>
            <array/>
            <key>CFBundleTypeName</key>
            <string>PDF</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>com.adobe.pdf</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Images</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.jpeg</string>
                <string>public.png</string>
                <string>public.tiff</string>
                <string>com.compuserve.gif</string>
            </array>
        </dict>
</array>
```

You can also add these by going to your target’s *Info* tab and enter the values into the *Document Types* section.

### Documentation

-   [Document types](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/DocumentInteraction_TopicsForIOS/Articles/RegisteringtheFileTypesYourAppSupports.html) from _Apple documentation_.

Handling incoming PDFs and images
---------------------------------

When your app is requested to handle a PDF or an image your `AppDelegate`’s `application(_:open:options:)` (__Swift__) or `application:openURL:options:` (__Obj-C__) method is called. You can read the data from the received `URL` into an `NSData` which can be uploaded to the Gini API for information extraction.

### Documentation

-   [AppDelegate resource handling](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623112-application) from _Apple Documentation_
-   [Submitting files](http://developer.gini.net/gini-api/html/documents.html#submitting-files) from _Gini API_
-   [Upload a document](http://developer.gini.net/gini-sdk-ios/docs/guides/common-tasks.html#upload-a-document) from _Gini API SDK_