![Gini Vision Library for iOS](./GiniVision_Logo.png?raw=true)

# Gini Vision Library for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()


The Gini Vision Library provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this library into your application you can allow your users to easily take a picture of a document, review it and - by implementing the necessary callbacks - upload the document for analysis to the Gini backend.

Communication with the Gini backend is not part of this library. You can either use the [Gini API SDK](https://github.com/gini/gini-sdk-ios) or implement communication with the Gini API yourself.

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

The Screen API provides a custom `UINavigationController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis. To start with the Screen API simply call `GiniVision.viewcontroller(withDelegate:)` and present it. Also make sure to pass an object conforming to the `GiniVisionDelegate` protocol. Optionally you can also pass in a configuration object to customize the UI of the Gini Vision Library.

Exemplary implementation Screen API:

```swift
let giniConfiguration = GiniConfiguration()
giniConfiguration.navigationBarItemTintColor = UIColor.white
giniConfiguration.backgroundColor = UIColor.white
present(GiniVision.viewController(withDelegate: self, withConfiguration: giniConfiguration), animated: true, completion: nil)
```

### Component API

The Component API provides a custom `UIViewController` for each of the four screens (onboarding, camera, review and analysis). This allows a maximum of flexibility, as the screens can be presented modally, used in a container view or pushed to a navigation view controller. Make sure to add your own navigational elements around the provided views.

Exemplary implementation Component API camera:

```swift
let cameraController = CameraViewController(success:
    { imageData in
        // Do something with the captured image
    }, failure: { error in
        print(error)
    })

@IBOutlet var containerView: UIView!
self.addChildViewController(cameraController)
cameraController.view.frame = self.containerView.bounds
self.containerView.addSubview(cameraController.view)
cameraController.didMove(toParentViewController: self)
```

To also use the `GiniConfiguration` with the Component API just use the `setConfiguration()` method of the `GiniVision` class.

```swift
let giniConfiguration = GiniConfiguration()
giniConfiguration.backgroundColor = UIColor.white
GiniVision.setConfiguration(giniConfiguration)
```

## Customization
The [Gini Vision Library UI Assets](https://github.com/gini/gini-vision-lib-assets) repository can be used as an aid for customizing the UI.

## Example

We are providing example apps for Swift and Objective-C. These apps demonstrate how to integrate the Gini Vision Library with the Screen API and Component API. The Gini API SDK is used to analyze the photos of documents. To run the example projects, clone the repo and run `pod install` from the Example or ExampleObjC directory first.

## Requirements

- iOS 9.0+
- Xcode 9.3+

**Note:**
In order to have better analysis results it is highly recommended to enable only devices with 8MP camera and flash. These devices would be:

* iPhones with iOS 9.0 or higher.
* iPad Pro devices (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash).


## Installation

Gini Vision Library can either be installed by using CocoaPods or by manually dragging the required files to your project.

**Note**: Irrespective of the option you choose if you want to support **iOS 10** you need to specify the `NSCameraUsageDescription` key in your `Info.plist` file. This key is mandatory for all apps since iOS 10 when using the `Camera` framework. Also if you're using the [Gini iOS SDK](https://github.com/gini/gini-sdk-ios) you need to add support for "Keychain Sharing" in your entitlements by adding a `keychain-access-groups` value to your entitlements file. For more information see the [Integration Guide](http://developer.gini.net/gini-sdk-ios/docs/guides/getting-started.html#integrating-the-gini-sdk) of the Gini iOS SDK.

### Swift versions

The Gini Vision Library is entirely (re-)written in **Swift 3**. **Swift 2.3** support can be found in a separate branch or the `2.3.3-beta` release. Please keep in mind that these versions are deprecated and will not receive any new features or bug fixes.

The last **Swift 2.2** release is `2.0.3`.

If you use CocoaPods you can specify a branch with:

```ruby
pod 'GiniVision', :git => 'https://github.com/gini/gini-vision-lib-ios.git', :branch => 'swift-2.3' # or use 'swift3'
```

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build Gini Vision Library.


To integrate Gini Vision Library into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/gini/gini-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod "GiniVision"
```

**Note:** You need to add Gini's podspec repository as a source.

Then run the following command:

```bash
$ pod install
```

### Manually

If you prefer not to use a dependency management tool, you can integrate the Gini Vision Library into your project manually.
To do so drop the GiniVision (classes and assets) folder into your project and add the files to your target.

Xcode will automatically check your project for swift files and will create an autogenerated import header for you.
Use this header in an Objective-C project by adding

```Obj-C
#import "YourProjectName-Swift.h"
```

to your implementation or header files. Note that spaces in your project name result in underscores. So `Your Project` becomes `Your_Project-Swift.h`.

## Branches

* `master` - Contains the latest stable release of the vision library.
* `develop` - The bleeding edge branch. Contains features actively in development and might be unstable.
* `swift-2.3` - Swift 2.3 support. _(Deprecated)_

## Author

Peter Pult, p.pult@gini.net

## License

The Gini Vision Library for iOS is licensed under a Private License. See the LICENSE file for more info.

**Important:** Always make sure to ship all license notices and permissions with your application.
