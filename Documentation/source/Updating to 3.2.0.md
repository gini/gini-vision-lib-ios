Updating to 3.2.0
=============================

GiniVision 3.2.0 introduces several new features and changes, empowering the apps and improving their user experience.  

This guide is provided in order to ease the transition of existing applications using _GiniVision_.

## Breaking Changes

### Camera screen
The UI of the Camera Screen has been updated for a better user experience. The document corner guides on the camera screen are now drawn programmatically, so you don't need to provide an overlay image for it anymore (`cameraOverlay` resource can be removed from assets). Now you only need to specify the color of the corner lines in the `GiniConfiguration.cameraPreviewCornerGuidesColor` property.

## Deprecation
* `GiniVisionDelegate.didCapture(imageData:)` - use the new `GiniVisionDelegate.didCapture(document:)` delegate method instead.
* `GiniVisionDelegate.didReview(imageData:withChanges:)` - use the new `GiniVisionDelegate.didReview(document:withChanges:)` delegate method instead.
* `AnalysisViewController.init(imageData:)` - use the new `AnalysisViewController.init(document:)` initializer instead.
* `CameraViewController.init(success:failure:)` - use the new `CameraViewController.init(successBlock: failureBlock:)` initializer instead.
* `ReviewViewController.init(imageData:success:failure:)` - use the new `ReviewViewController.init(document:successBlock:failureBlock:)` initializer instead.

## New features
### Document Import
The Document Import feature allows users to select images (jpeg, png and gif) and PDFs from their device or from their cloud storage (_iCloud_, _Dropbox_...). The selected document will be made available to the client and may be optionally verified before accepting it for upload and analysis.
To implement this feature you can follow [Import PDFs and Images guide](Import-pdfs-and-images-guide.html).

### Open with
With the _Open with_ feature now is possible to open files from other apps like _Mail_ or _Whatsapp_. More information about this and how to implement it can be found in the [Open with guide](Open-with-guide.html) 

### New Camera Screen UI
The UI of the Camera Screen has been redesigned to offer a better user experience. Apart from the corner guides described and the dimmed borders on the preview, a new button for Document import (that can be replaced adding the `documentImportButton` asset) has been added next to the Capture button. Additionally a hint will appear the first time after updating the library, being possible to customize all its properties (color, text or close button color) in the `GiniConfiguration` instance.

### New Analysis Screen UI
The UI of the Anaysis Screen has been also redesign, giving more information to the user. When a _PDF_ is analysed, a panel information will appear on the top of the screen indicating _PDF_ name and the number of pages. Both the background color and text color of the panel can be customized through `GiniConfiguration.analysisPDFInformationTextColor` and `GiniConfiguration.analysisPDFInformationBackgroundColor` properties.

When an image is being analysed and is taking more than 5 seconds to do it the Gini Vision Library cycles through tips, showing each one for 4 seconds. The tips, that are shown on the bottom of the Screen, are intended to help our users achieve better results by offering them advice on how to take photos most suitable for analysis.

### Help screens
To aid users in discovering and learning about the features of the Gini Vision Library, and how to best use them, we added help screens. These can be viewed from the Camera Screen.

On the one hand, using the __Screen API__, the top right button in the Camera Screen will now launch the HelpActivity instead of showing the Onboarding Screens. And on the other hand, when using the __Component API__, you need to launch the `HelpMenuViewController` manually.

From the Help Screen the following screens can be reached:

* __Photo Tips Screen__: 

Information about how to take good pictures. The images of this screen can be changed adding `captureSuggestion1`, `captureSuggestion2`, `captureSuggestion3` and `captureSuggestion4` assets into your project.

* __File Import Screen__: 

A guide on how to import files from other apps via “open with”. Images can be changed adding `openWithTutorialStep1`, `openWithTutorialStep2` and `openWithTutorialStep3` assets into your project. Texts also can be changed adding `ginivision.help.openWithTutorial.step1.title`, 
`ginivision.help.openWithTutorial.step1.subTitle`, `ginivision.help.openWithTutorial.step2.title`, 
`ginivision.help.openWithTutorial.step2.subTitle`, `ginivision.help.openWithTutorial.step3.title` and 
`ginivision.help.openWithTutorial.step3.subTitle` to your `X.strings` file.

* __Supported Formats Screen__: 

Information about the document formats supported by the Gini Vision Library. Both supported and unsupported icon circle color can be changed in `GiniConfiguration.supportedFormatsIconColor` and `GiniConfiguration.nonSupportedFormatsIconColor` properties.

### No results screen

The Gini Vision Library contains a new screen providing tips for users in order to achieve better results from images, displayed only for pictures taken by the camera and imported images.

The No Results Screen should be requested only when none of the required extractions were received.

When using the __Screen API__, once the analysis has been completed you can call the `AnalysisDelegate.displayNoResultsScreen()` as follows:

```swift
if hasPayFive {
	// Show the extractions
} else {            
	DispatchQueue.main.async { [weak self] in
		self?.analysisDelegate?.displayNoResultsScreen { shown in
			if !shown { 
				// Show custom no results screen or exit Screen API
			}
			self?.analysisDelegate = nil
		}
	}
}
```

### iPad support
On iPad, unlike the iPhone, the Gini Vision Library UI supports both landscape and portrait orientations, full rotation being enabled by default in both APIs (*Screen* and *Component*). So in case you don't want a particular orientation, you need to disable it in your project settings (*Project Settings &rarr; General &rarr; Deployment Info &rarr; Device orientation*).

If you want to modify the images shown on both Onboarding screen and No Results screen, keep in mind that the device image (`onboardingPage1` and `captureSuggestion4` assets) is different for iPhone and iPads, so it should be necessary also to provide also a version for iPad. 

#### Extraction Quality Considerations
We recommend implementing checks on tablet hardware to ensure that devices meet the Gini Vision Libraries minimum recommended hardware specifications.

Many iPads with at least 8MP cameras don’t have an LED flash (iPad Air 2 and iPad Mini 4 have 8MP camera but no flash). For this reason the extraction quality on those tablets might be lower compared to smartphones.

