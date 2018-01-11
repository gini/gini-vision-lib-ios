QR Code Scanning
=============================

Some invoices have a QR Code that allows the user to get the payment data just scanning it from the camera screen. If the QR Code has a valid format (see [supported QR Codes](#supported-qr-codes)), a popup appears pointing out that a QR Code has been detected and allowing the user to use it.
<center><img src="img/qr_code_popup.jpg" border="1"/></center>

Enable QR Code scanning
----------------------

The QR Code scanning feature is disabled by default, so in case that you what to use it you just need to enable it in the `GiniConfiguration`, like so:
```swift
let giniConfiguration = GiniConfiguration()
...
...
...		
giniConfiguration.qrCodeScanningEnabled = true
```

Handle the Payment Data
----------------------

Once the QR Code has been detected and the user has tapped the button to use it, the payment data is returned. In order to handle the Payment Data from the QR Code, on the one hand if you are using the _Screen API_ you have to implement the delegate method `GiniVisionDelegate.didDetect(qrDocument:)` to get the `GiniQRCodeDocument`.
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

Also the text from both label and button can be also modified through the following parameters in your `Localizable.strings` file:
- _ginivision.camera.qrCodeDetectedPopup.buttonTitle_
- _ginivision.camera.qrCodeDetectedPopup.message_


Supported QR Codes
----------------------

The supported QR Codes are:
- [BezahlCode](http://www.bezahlcode.de)
- [EPC069-12](https://www.europeanpaymentscouncil.eu/document-library/guidance-documents/quick-response-code-guidelines-enable-data-capture-initiation)
- [Stuzza (AT)](https://www.stuzza.at/de/zahlungsverkehr/qr-code.html)
- [GiroCode (DE)](https://www.girocode.de/rechnungsempfaenger/)
