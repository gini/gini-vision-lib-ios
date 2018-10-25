Integration
=============================

The Gini Vision Library provides two integration options. A [Screen API](#screen-api) that is easy to implement and a more complex, but also more flexible [Component API](#component-api). Both APIs can access the complete functionality of the library.

**Note**: Irrespective of the option you choose if you want to support **iOS 10** you need to specify the `NSCameraUsageDescription` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when using the `Camera` framework. Also if you're using the [Gini iOS SDK](https://github.com/gini/gini-sdk-ios) you need to add support for "Keychain Sharing" in your entitlements by adding a `keychain-access-groups` value to your entitlements file. For more information see the [Integration Guide](http://developer.gini.net/gini-sdk-ios/docs/guides/getting-started.html#integrating-the-gini-sdk) of the Gini iOS SDK.

## Screen API

The Screen API provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.
The Screen API, in turn, offers two different ways of implementation:

#### UI with Networking (Recommended)
Using this method you don't need to care about handling the analysis process with the [Gini API SDK](https://github.com/gini/gini-sdk-ios), you only need to provide your API credentials and a delegate to get the analysis results. Optionally - if you want to use _Certificate pinning_ - you can provide your public key pinning configuration (see [TrustKit repo](https://github.com/datatheorem/TrustKit) for more information), and - if you want to provide metadata for the upload process - you can specify it as follows:

```swift
let viewController = GiniVision.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: self,
                                               publicKeyPinningConfig: pinningConfig,
                                               documentMetadata: documentMetadata)

present(viewController, animated: true, completion:nil)
```


#### Only UI

In case that you decide to use only the UI and to handle all the analysis process (either using the [Gini API SDK](https://github.com/gini/gini-sdk-ios) or with your own implementation of the API), just get the `UIViewController` as follows:

```swift
let viewController = GiniVision.viewController(withDelegate: self,
                                               withConfiguration: giniConfiguration)

present(viewController, animated: true, completion: nil)
```

## Component API

The Component API provides a custom `UIViewController` for each screen. This allows a maximum of flexibility, as the screens can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

To also use the `GiniConfiguration` with the Component API just use the `GiniVision.setConfiguration(_:)` as follows:

```swift
let giniConfiguration = GiniConfiguration()
.
.
.
GiniVision.setConfiguration(giniConfiguration)
```

The components that can be found in the library are:
* **Camera**: The actual camera screen to capture the image of the document, to import a PDF or an image or to scan a QR Code (`CameraViewController`).
* **Review**: Offers the opportunity to the user to check the sharpness of the image and eventually to rotate it into reading direction (`ReviewViewController`).
* **Multipage Review**: Allows to check the quality of one or several images and the possibility to rotate and reorder them (`MultipageReviewViewController`).
* **Analysis**: Provides a UI for the analysis process of the document by showing the user capture tips when an image is analyzed or the document information when it is a PDF. In both cases an image preview of the document analyzed will be shown (`AnalysisViewController`).
* **Help**: Helpful tutorials indicating how to use the open with feature, which are the supported file types and how to capture better photos for a good analysis (`HelpMenuViewController`).
* **No results**: Shows some suggestions to capture better photos when there are no results after an analysis (`ImageAnalysisNoResultsViewController`).
