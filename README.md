![Gini Vision Library for iOS](./GiniVision_Logo.png?raw=true)

# Gini Vision Library for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-4.1-orange.svg)]()


The Gini Vision Library provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this library into your application you can allow your users to easily take a picture of a document, review it and get analysis results from the Gini backend.

The Gini Vision Library can be integrated in two ways, either by using the *Screen API* or the *Component API*. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is based on our long-lasting experience with integration in customer apps. In the Component API, we provide independent views so you can design your own application as you wish. We strongly recommend keeping in mind our UI/UX guidelines, however.

On *iPhone*, the Gini Vision Library has been designed for portrait orientation. In the Screen API, orientation is automatically forced to portrait when being displayed. In case you use the Component API, you should limit the view controllers orientation hosting the Component API's views to portrait orientation. This is specifically true for the camera view.

## Documentation

Further documentation with installation, integration or customization guides can be found in our [website](http://developer.gini.net/gini-vision-lib-ios/docs/).

## Example

We are providing example apps for Swift and Objective-C. These apps demonstrate how to integrate the Gini Vision Library with the Screen API and Component API. To run the example project, clone the repo and run `pod install` from the Example directory first.
To inject your API credentials into the Example app, just add to the Example directory the `Credentials.plist` file with the following format:

<img border=1 src=credentials_plist_format.png/>

## Requirements

- iOS 9.0+
- Xcode 9.3+

**Note:**
In order to have better analysis results it is highly recommended to enable only devices with 8MP camera and flash. These devices would be:

* iPhones with iOS 9.0 or higher.
* iPad Pro devices (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash).

## Author

Gini GmbH, hello@gini.net

## License

The Gini Vision Library for iOS is licensed under a Private License. See [the license](http://developer.gini.net/gini-vision-lib-ios/docs/license.html) for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
