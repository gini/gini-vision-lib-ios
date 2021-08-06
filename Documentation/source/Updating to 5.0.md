Updating to 5.0
=============================

## What's new?
---

#### New API SDK -> Gini Library
[Gini Library for iOS](https://github.com/gini/gini-ios)
The networking plugin now uses the new API SDK, which has been completely rewritten in Swift, getting rid of  **Bolts** and using only built-in components.

#### New way to open incoming files
There is a new way to handle incoming documents through the "Open with.../Copy to..." iOS feature. Please refer to the guide page [Open with guide](open-with-guide.html).

## Breaking Changes
---

#### Removed support for iOS 9
In order to use the new API SDK, to improve the codebase and since iOS 9.0 adoption is lower than 1% nowadays, the minimun deployment target is iOS 10.0 now.

#### Removed _GiniClient_ type
The _GiniClient_ has been removed, using now the new `Client` type in the new API SDK.

#### Removed Obj-C support for networking plugin
Now the networking plugin uses the new API SDK, which does not support Obj-C and therefore it's not compatible.

#### Removed deprecated code
Old deprecated code in previous versions has been removed, which includes the following:
* All localized strings variables in the `GiniConfiguration`. Now it uses the `Localizable.strings` file.
* All the custom font variables. Now the `GiniConfiguration.customFont` is used.
* The initializers for the `CameraViewController`, `ReviewViewController` and `AnalysisViewController`.
* The `validate` method in the `GiniVisionDocument`. The `GiniVisionDocumentValidator` should be used instead.
* The left navigation bar button item setting has been removed from the `HelpMenuViewController`.
