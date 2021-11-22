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

 In order to handle the Payment Data from the QR code, if you are using the _Screen API_ the `GiniQRCodeDocument` is received in the delegate method `GiniVisionDelegate.didCapture(document:)`, where it must be sent to the API as though it was an image or a pdf.
 
```swift
func didCapture(document: GiniVisionDocument, networkDelegate: GiniVisionNetworkDelegate) {
// The EPS QR codes are a special case, since they don't have to be analyzed by the Gini API and therefore,
// they are ready to be delivered after capturing them.
if let qrCodeDocument = document as? GiniQRCodeDocument,
    let format = qrCodeDocument.qrCodeFormat,
    case .eps4mobile = format {
    let result = qrCodeDocument.extractedParameters.compactMap {
        Extraction(box: nil, candidates: nil,
                    entity: QRCodesExtractor.epsCodeUrlKey,
                    value: $0.value,
                    name: QRCodesExtractor.epsCodeUrlKey)
        }
    let extractionResult = ExtractionResult(extractions: result, candidates: [:])
    
    self.deliver(result: extractionResult, analysisDelegate: networkDelegate)
    return
}
 ```       
 retrieve the extractions and exit the Gini Vision Library to use the payment data in your application. You should also send feedback for the QR Codes. Basically you need to execute the same steps as for images, but instead of uploading an image you upload the contents of the QRCodeDocument.

If you are using the _Component API_, you will get the `GiniQRCodeDocument` in the `CameraScreenSuccessBlock`, where it also must be sent to the API as if it was an image or a pdf.

#### Note:
---
If you are using the [Gini Library for iOS](https://github.com/gini/gini-ios) to send the documents to the Gini API, you have to update to `0.5.2` in order to analyze the QR Codes.

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
