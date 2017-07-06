How to Upload PDFs and Images
=============================

General considerations
----------------------

Enabling your app to open PDFs and images allows your users to open any kind of files which are identified by the OS as PDFs or images. Make sure to check the MIME type and that the file size is below an acceptable threshold (5MB for example). It is also advisable to check the first bytes of the incoming files to determine their type and allow only PDFs and known image types.

Registering PDF and image file types
------------------------------------

Add the following to your ``Info.plist``:

.. code-block:: xml

    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>PDF</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>com.adobe.pdf</string>
            </array>
        </dict>
        <dict>
            <key>CFBundleTypeName</key>
            <string>Image</string>
            <key>LSHandlerRank</key>
            <string>Alternate</string>
            <key>LSItemContentTypes</key>
            <array>
                <string>public.image</string>
            </array>
        </dict>
    </array>

You can also add these by going to your target’s *Info* tab and enter the values into the *Document Types* section.

Documentation
^^^^^^^^^^^^^

- https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/DocumentInteraction_TopicsForIOS/Articles/RegisteringtheFileTypesYourAppSupports.html

Handling incoming PDFs and images
---------------------------------

When your app is requested to handle a PDF or an image your ``AppDelegate``’s ``application(_:open:options:)`` (Swift) or ``application:openURL:options:`` (Obj-C) method is called. You can read the data from the received ``URL`` into an ``NSData`` which can be uploaded to the Gini API for information extraction.

Documentation
^^^^^^^^^^^^^

- Apple: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623112-application
- Gini API: http://developer.gini.net/gini-api/html/documents.html#submitting-files
- Gini API SDK: http://developer.gini.net/gini-sdk-ios/docs/guides/common-tasks.html#upload-a-document

Showing a preview of the PDF’s first page
-----------------------------------------

We recommend showing a preview of the PDF’s first page or of the image while the document is being analyzed.
 
The following method shows how to generate a preview of the PDF’s first page (Swift):

.. code-block:: swift

    func image(fromPDFURL url: NSURL?) -> UIImage? {
            guard let url = url else { return nil }
            guard let pdf = CGPDFDocumentCreateWithURL(url as CFURL) else { return nil }
            guard let page = CGPDFDocumentGetPage(pdf, 1) else { return nil }
            let pageRect = CGPDFPageGetBoxRect(page, .MediaBox)
            UIGraphicsBeginImageContext(pageRect.size)
            let ctx = UIGraphicsGetCurrentContext()
            UIColor.whiteColor().set()
            CGContextFillRect(ctx, pageRect)
            CGContextTranslateCTM(ctx, 0, pageRect.size.height)
            CGContextScaleCTM(ctx, 1.0, -1.0)
            CGContextDrawPDFPage(ctx, page)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
    }

As it uses *Core Graphics* the Objective-C version is very similar. The returned image can be used on the analysis screen.

Documentation
^^^^^^^^^^^^^

- https://developer.apple.com/library/content/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_pdf/dq_pdf.html#//apple_ref/doc/uid/TP30001066-CH214-TPXREF101
