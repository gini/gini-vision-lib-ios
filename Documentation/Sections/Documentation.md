![Gini Vision Library for iOS](img/GiniVision_Logo.png)

# Gini Vision Library for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()


The Gini Vision Library provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this library into your application you can allow your users to easily take a picture of a document, review it and - by implementing the necessary callbacks - upload the document for analysis to the Gini backend.

Communication with the Gini backend is not part of this library. You can either use the [Gini API SDK](https://github.com/gini/gini-sdk-ios) or implement communication with the Gini API yourself.

The Gini Vision Library can be integrated in two ways, either by using the *Screen API* or the *Component API*. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is based on our long-lasting experience with integration in customer apps. In the Component API, we provide independent views so you can design your own application as you wish. We strongly recommend keeping in mind our UI/UX guidelines, however.

On *iPhone*, the Gini Vision Library has been designed for portrait orientation. In the Screen API, orientation is automatically forced to portrait when being displayed. In case you use the Component API, you should limit the view controllers orientation hosting the Component API's views to portrait orientation. This is specifically true for the camera view.

##Contents

* [Installation](installation.html)
* [Updating to 3.2](updating-to-32.html)
* [Open with guide](open-with-guide.html)
* [Import PDFs and Images guide](import-pdfs-and-images-guide.html)
* [QR Code scanning guide](qr-code-scanning-guide.html)
* [Changelog](changelog.html)
* [License](license.html)

##API

* [Classes](Classes.html)
* [Enums](Enums.html)
* [Protocols](Protocols.html)
* [Typealiases](Typealiases.html)
