Integration
=============================

As mentioned before the Gini Vision Library provides two integration options. A [Screen API](#screen-api) that is easy to implement and a more complex, but also more flexible [Component API](#component-api). Both APIs can access the complete functionality of the library.

## Screen API

The Screen API provides a custom `UIViewController` object, which can be presented modally. It handles the complete process from showing the onboarding until providing a UI for the analysis.
The Screen API, in turn, offers two different ways of implementation:

#### UI with Networking (Recommended)
Using this method you don't need to care about handling the analysis process with the [Gini API SDK](https://github.com/gini/gini-sdk-ios), you only need to provide your API credentials and a delegate to get the analysis results. Optionally - if you want to use _Certificate pinning_ - you can provide your public key pinning configuration.

```swift
let viewController = GiniVision.viewController(withClient: client,
                                               configuration: giniConfiguration,
                                               resultsDelegate: self,
                                               publicKeyPinningConfig: pinningConfig)

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

To also use the `GiniConfiguration` with the Component API just use the `setConfiguration()` method of the `GiniVision` class.

```swift
let giniConfiguration = GiniConfiguration()
giniConfiguration.backgroundColor = UIColor.white
GiniVision.setConfiguration(giniConfiguration)
```
