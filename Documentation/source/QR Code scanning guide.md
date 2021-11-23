QR Code Scanning
=============================

Some invoices have a QR code that allows the user to get the payment data just by scanning it from the camera screen. If the QR code has a valid format (see [supported QR codes](#supported-qr-codes)), a popup appears pointing out that a QR code has been detected and allowing the user to use it.
<center><img src="img/qr_code_popup.jpg" border="1"/></center>

Enable QR code scanning
----------------------

The QR code scanning feature is disabled by default, so in case that you what to use it you just need to enable it in the `GiniConfiguration`, like so:
```swift
let giniConfiguration = GiniConfiguration()
...
...
...		
giniConfiguration.qrCodeScanningEnabled = true
```

Handle and process the Payment Data
------------------------------------

Once the QR code has been detected and the user has tapped the button to use it, the payment data is returned and ready to be analyzed in the API.

---
**NOTE**

Please remember you **_should not mix diffent document types_** like QR codes with captured images and pdfs.

---
Screen API
-----------

In order to handle the Payment Data from the QR code, if you are using the _Screen API_ the `GiniQRCodeDocument` is received in the delegate method `GiniVisionDelegate.didCapture(document:)`, where it must be sent to the API as though it was an image or a pdf. After uploading and retrieving the extractions you should also send feedback for the QR Codes. Basically you need to execute the same steps as for images, but instead of uploading an image you upload the contents of the QRCodeDocument.

Component API
--------------

If you are using the _Component API_, you will get the `GiniQRCodeDocument` in the `CameraScreenSuccessBlock`, where it also must be sent to the API as if it was an image or a pdf.

In order to avoid unsuccessful document processing we suggest to validate captured and imported documents. 
You can find validation implementation examples for captured documents
[here](https://github.com/gini/gini-vision-lib-ios/blob/master/Example/Example%20Swift/ComponentAPICoordinator.swift#L652) and for imported ones
[here](https://github.com/gini/gini-vision-lib-ios/blob/master/Example/Example%20Swift/ComponentAPICoordinator.swift#L676).

---
**NOTE**

 We highly recommend you to validate the partial documents before creating the composite document  from them.

---

You can find an example of implementation for [captured](https://github.com/gini/gini-vision-lib-ios/blob/master/Example/Example%20Swift/ComponentAPICoordinator.swift#L466) and [imported](https://github.com/gini/gini-vision-lib-ios/blob/master/Example/Example%20Swift/ComponentAPICoordinator.swift#L519) documents.

---
**NOTE**

If you are using the [Gini Library for iOS](https://github.com/gini/gini-ios) to send the documents to the Gini API, you have to update to `0.5.2` in order to analyze the QR Codes.

---
Customization
----------------------
It is possible to customize the text label, button and background colors with these parameters:
- `GiniConfiguration.qrCodePopupBackgroundColor`
- `GiniConfiguration.qrCodePopupButtonColor`
- `GiniConfiguration.qrCodePopupTextColor`

Additionally the text from both label and button can be customized through the following parameters in your `Localizable.strings` file:
- _ginivision.camera.qrCodeDetectedPopup.buttonTitle_
- _ginivision.camera.qrCodeDetectedPopup.message_


Supported QR codes
----------------------

The supported QR codes are:
- [BezahlCode](http://www.bezahlcode.de)
- [EPC069-12](https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation)
- [Stuzza (AT)](https://www.stuzza.at/de/zahlungsverkehr/qr-code.html)
- [GiroCode (DE)](https://www.girocode.de/rechnungsempfaenger/)
