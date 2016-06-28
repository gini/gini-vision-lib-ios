# GiniVision

[![CI Status](https://travis-ci.com/gini/gini-vision-lib-ios.svg?token=TvDgN64LcAHcyTDy8g4j&branch=master)](https://travis-ci.com/gini/gini-vision-lib-ios)

The Gini Vision Library provides componentes for capturing, reviewing and analysing photos with invoices and remittance slips.

By integrating this library in your application you can allow your users to easily take pictures of documents, review them and - by implementing the necessary callbacks - upload the document for analysis to the Gini backend.

Communicating with the Gini backend is not part of this library. You can either use the [Gini API SDK](https://github.com/gini/gini-sdk-ios) or implement communicating with the Gini API yourself.

The Gini Vision Library can be integrated in two ways, either by using the Screen API or the Component API. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is influenced by our long-lasting experience with integration in customer apps. In the Component API, we provide independent views. So, you can design your own application as you wish (but keep in mind our your UI/UX guidelines).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0+
- Xcode 7.3+

## Installation

GiniVision can either be installed by using CocoaPods or by manually dragging required files to your project.

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build GiniVision.

To integrate GiniVision into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod "GiniVision"
```

Then, run the following command:

```bash
$ pod install
```

## Author

Peter Pult, p.pult@gini.net

## License

GiniVision is available under a commercial license. See the LICENSE file for more info.
