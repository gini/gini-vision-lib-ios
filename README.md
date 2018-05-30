![Gini Vision Library for iOS](./GiniVision_Logo.png?raw=true)

# Gini Vision Library for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-4.1-orange.svg)]()


The Gini Vision Library provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this library into your application you can allow your users to easily take a picture of a document, review it and - by implementing the necessary callbacks - upload the document for analysis to the Gini backend.

The Gini Vision Library can be integrated in two ways, either by using the *Screen API* or the *Component API*. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is based on our long-lasting experience with integration in customer apps. In the Component API, we provide independent views so you can design your own application as you wish. We strongly recommend keeping in mind our UI/UX guidelines, however.

On *iPhone*, the Gini Vision Library has been designed for portrait orientation. In the Screen API, orientation is automatically forced to portrait when being displayed. In case you use the Component API, you should limit the view controllers orientation hosting the Component API's views to portrait orientation. This is specifically true for the camera view.

## Documentation

Further documentation can be found in our [website](http://developer.gini.net/gini-vision-lib-ios/docs/)

## Architecture

The Gini Vision Library consists of three main screens

* Camera: The actual camera screen to capture the image of the document or to import either a PDF or an image.
* Review: Offers the opportunity to the user to check the sharpness of the image and eventually to rotate it into reading direction.
* Analysis: Provides a UI for the analysis process of the document by showing the user capture tips when an image is analyzed or the document information when it is a PDF. In both cases an image preview of the document analyzed will be shown.

As mentioned before the Gini Vision Library provides two integration options. A Screen API that is easy to implement and a more complex, but also more flexible Component API. Both APIs can access the complete functionality of the library.

### Screen API

The Screen API provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.
The Screen API, in turn, offers two different ways of implementation:

##### UI with Networking (Recommended)
Using this method you don't need to care about handling the analysis process with the [Gini API SDK](https://github.com/gini/gini-sdk-ios), you only need to provide your API credentials and a delegate to get the analysis results. Optionally - if you want to use _Certificate pinning_ - you can provide your public key pinning configuration.

```swift
let viewController = GiniVision.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: self,
                                               publicKeyPinningConfig: pinningConfig)

present(viewController, animated: true, completion:nil)
```


##### Only UI

In case that you decide to use only the UI and to handle all the analysis process (either using the [Gini API SDK](https://github.com/gini/gini-sdk-ios) or with your own implementation of the API), just get the `UIViewController` as follows:

```swift
let viewController = GiniVision.viewController(withDelegate: self,
                                               withConfiguration: giniConfiguration)

present(viewController, animated: true, completion: nil)
```

### Component API

The Component API provides a custom `UIViewController` for each screen. This allows a maximum of flexibility, as the screens can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

To also use the `GiniConfiguration` with the Component API just use the `setConfiguration()` method of the `GiniVision` class.

```swift
let giniConfiguration = GiniConfiguration()
giniConfiguration.backgroundColor = UIColor.white
GiniVision.setConfiguration(giniConfiguration)
```

## Customization
The [Customization guide](http://developer.gini.net/gini-vision-lib-ios/docs/customization-guide.html) can be used as an aid for customizing the UI.

## Example

We are providing example apps for Swift and Objective-C. These apps demonstrate how to integrate the Gini Vision Library with the Screen API and Component API. To run the example projects, clone the repo and run `pod install` from the Example directory first.
To inject your API credentials into the Example app, just add to the Example directory the `Credentials.plist` file with the following format:

<img border=1 src=credentials_plist_format.png/>

## Requirements

- iOS 9.0+
- Xcode 9.3+

**Note:**
In order to have better analysis results it is highly recommended to enable only devices with 8MP camera and flash. These devices would be:

* iPhones with iOS 9.0 or higher.
* iPad Pro devices (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash).


## Installation

[Customization guide](http://developer.gini.net/gini-vision-lib-ios/docs/installation.html)


## Author

Gini GmbH, hello@gini.net

## License

The Gini Vision Library for iOS is licensed under a Private License. See the LICENSE file for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
