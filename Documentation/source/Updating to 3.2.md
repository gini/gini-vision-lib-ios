Updating to 3.2
=============================

GiniVision 3.2 introduces several new features and changes, empowering your app and improving the user experience.  

This guide is provided in order to ease the transition of existing applications using _GiniVision_.

## Breaking Changes

### Camera screen
The UI of the Camera Screen has been updated for a better user experience. The document corner guides on the camera screen are now drawn programmatically, so you don't need to provide an overlay image for it anymore (`cameraOverlay` resource should be removed from assets). Now you only need to specify the color of the corner lines in the `GiniConfiguration.cameraPreviewCornerGuidesColor` property.

## Deprecation
* `GiniVisionDelegate.didCapture(_:)` - use the new `GiniVisionDelegate.didCapture(document:)` delegate method instead.
* `GiniVisionDelegate.didReview(_:withChanges:)` - use the new `GiniVisionDelegate.didReview(document:withChanges:)` delegate method instead.
* `AnalysisViewController.init(_:)` - use the new `AnalysisViewController.init(document:)` initializer instead.
* `CameraViewController.init(success:failure:)` - use the new `CameraViewController.init(successBlock:failureBlock:)` initializer instead.
* `ReviewViewController.init(_:success:failure:)` - use the new `ReviewViewController.init(_:successBlock:failureBlock:)` initializer instead.

## New features
### Document Import
The Document Import feature is located on the Camera Screen and allows users to select images (jpeg, png and gif) and PDFs of invoices from their device or from their cloud storage (_iCloud_, _Dropbox_...). The selected document will be made available to the client and may be optionally verified before accepting it for upload and analysis.
To implement this feature you can follow [Import PDFs and Images guide](Import-pdfs-and-images-guide.html).

### Open with
With the _Open with_ feature now is possible to open files from other apps like _Mail_ or _Whatsapp_. More information about this and how to implement it can be found in the [Open with guide](Open-with-guide.html)

### New Camera Screen UI
The UI of the Camera Screen has been redesigned to offer a better user experience. Apart from the corner guides, described above, and the dimmed borders on the preview, a new button for Document import (that can be replaced adding the `documentImportButton` asset). All the properties of the hint (color, text or close button color) can be customized in the `GiniConfiguration` instance.

### New Analysis Screen UI
The UI of the Anaysis Screen has also been redesigned, to accomodate opening PDFs and to provide additional information to the user. When a _PDF_ is analysed, an information panel will appear on the top of the screen indicating _PDF_ name and the number of pages. Both the background color and text color of the panel can be customized through the `GiniConfiguration.analysisPDFInformationTextColor` and `GiniConfiguration.analysisPDFInformationBackgroundColor` properties.

When analysing an image takes more than 5 seconds, the Gini Vision Library cycles through tips, showing each one for 4 seconds. The tips, which are shown on the bottom of the Screen, are intended to help our users achieve better results by offering them advice on how to take photos most suitable for analysis.

### Help screens
To aid users in discovering and learning about the features of the Gini Vision Library, and how to best use them, we added help screens. These can be viewed from the Camera Screen.

If using the __Screen API__, the top right button in the Camera Screen will now launch the HelpActivity instead of showing the Onboarding Screens. If using the __Component API__, you need to launch the `HelpMenuViewController` manually.

From the Help Screen the following screens can be reached:

* __Photo Tips Screen__:

Information to the user about how to take photos suitable for analysis. The images of this screen can be changed adding `captureSuggestion1`, `captureSuggestion2`, `captureSuggestion3` and `captureSuggestion4` assets into your project.

* __File Import Screen__:

A guide on how to import files from other apps via “open with”. Images can be changed adding `openWithTutorialStep1`, `openWithTutorialStep2` and `openWithTutorialStep3` assets into your project. Texts also can be changed adding `ginivision.help.openWithTutorial.step1.title`,
`ginivision.help.openWithTutorial.step1.subTitle`, `ginivision.help.openWithTutorial.step2.title`,
`ginivision.help.openWithTutorial.step2.subTitle`, `ginivision.help.openWithTutorial.step3.title` and
`ginivision.help.openWithTutorial.step3.subTitle` to your `X.strings` file.

* __Supported Formats Screen__:

Information about the document formats supported by the Gini Vision Library. Both supported and unsupported icon circle color can be changed in `GiniConfiguration.supportedFormatsIconColor` and `GiniConfiguration.nonSupportedFormatsIconColor` properties.

All these new assets can be found in the [Gini Vision Library UI Assets](https://github.com/gini/gini-vision-lib-assets) repository.

### No results screen

The Gini Vision Library contains a new screen providing tips for users in order to achieve better results from images. This screen is displayed only for images (pictures taken by the camera and imported images).

The No Results Screen should be requested only when none of the required extractions were received.

When using the __Screen API__, once the analysis has been completed you can call the `AnalysisDelegate.tryDisplayNoResultsScreen()` as follows:

```swift
if hasExtractions {
	// Show the extractions
} else {
	let shown = analysisDelegate.tryDisplayNoResultsScreen()
	if !shown {
		let customNoResultsScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "noResultScreen") as! NoResultViewController
		self.navigationController!.pushViewController(customNoResultsScreen, animated: true)
		self.dismiss(animated: true, completion: nil)
	}
	self.analysisDelegate = nil
}
```

### Custom font
Now it is possible to specify a custom font for the whole library, being not needed to specify a font for each text.
You just need to specify the `GiniVisionFont` in the `GiniConfiguration.customFont` property. Previously defined fonts are no longer needed (`NavigationBarItemFont`, `NavigationBarTitleFont`, `NoticeFont`, `CameraNotAuthorizedTextFont`, `CameraNotAuthorizedButtonFont`, `OnboardingTextFont`,`ReviewTextTopFont` and `ReviewTextBottomFont`).

### iPad support
On iPad, unlike the iPhone, the Gini Vision Library UI supports both landscape and portrait orientations, full rotation being enabled by default in both APIs (*Screen* and *Component*). So in case you don't want a particular orientation, you will need to disable it in your project settings (*Project Settings &rarr; General &rarr; Deployment Info &rarr; Device orientation*).

If you want to modify the images shown on both Onboarding screen and No Results screen, keep in mind that the device image (`onboardingPage1` and `captureSuggestion4` assets) is different for iPhone and iPads, so it will also be necessary to provide a version for iPad.

#### Extraction Quality Considerations
We recommend implementing checks on tablet hardware to ensure that devices meet the Gini Vision Libraries minimum recommended hardware specifications.

Many iPads with at least 8MP cameras don’t have an LED flash (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash). For this reason the extraction quality on those tablets might be lower compared to smartphones.
