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

Handle the Payment Data
----------------------

Once the QR code has been detected and the user has tapped the button to use it, the payment data is returned. In order to handle the Payment Data from the QR code, on one hand if you are using the _Screen API_ you have to implement the delegate method `GiniVisionDelegate.didDetect(qrDocument:)` to get the `GiniQRCodeDocument`.
```swift
func didDetect(qrDocument: GiniQRCodeDocument) {
	let paymentParameters = qrDocument.extractedParameters
	...
}
```

On the other hand if your are using the _Component API_, you will get the `GiniQRCodeDocument` in the `CameraScreenSuccessBlock` as follows:
```swift
let cameraViewController = CameraViewController(successBlock: { document in
		if let qrDocument = document as? GiniQRCodeDocument {
			let paymentParameters = qrDocument.extractedParameters
			...
		}
		...      
	}, failureBlock: { error in
    ...
})
```

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
