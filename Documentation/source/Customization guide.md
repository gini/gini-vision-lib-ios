Customization guide
=============================

The Gini Vision Library components can be customized either through the `GiniConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Generic components](#generic-components)
- [Camera screen](#camera-screen)
- [Review screen](#review-screen)
- [Multipage Review screen](#multipage-review-screen)
- [Analysis screen](#analysis-screen)
- [Supported formats screen](#supported-formats-screen)
- [Open with tutorial screen](#open-with-tutorial-screen)
- [Capturing tips screen](#capturing-tips-screen)
- [Gallery album screen](#gallery-album-screen)

Customizable assets can be found in [the Assets repo](https://github.com/gini/gini-vision-lib-assets).

## Generic components

##### 1. Navigation bar
<center><img src="img/Customization guide/Navigation bar.jpg" height="70"/></center>
- Tint color &#8594;  `GiniConfiguration.navigationBarTintColor`
- Item tint color &#8594;  `GiniConfiguration.navigationBarItemTintColor`
- Title color &#8594;  `GiniConfiguration.navigationBarTitleColor`
- Item font &#8594;  `GiniConfiguration.navigationBarItemFont`
- Title font &#8594;  `GiniConfiguration.navigationBarTitleFont`

##### 2. Notice
<center><img src="img/Customization guide/Notice.jpg" height="70"/></center>
- Information background color &#8594;  `GiniConfiguration.noticeInformationBackgroundColor`
- Information text color &#8594;  `GiniConfiguration.noticeInformationTextColor`
- Error background &#8594;  `GiniConfiguration.noticeErrorBackgroundColor`
- Error text color `GiniConfiguration.noticeErrorTextColor`

##### 2. GVL font

- Font &#8594;  `GiniConfiguration.customFont`

## Camera screen

<br>
<center><img src="img/Customization guide/Camera.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.camera.title*</span> localized string
- Close button
	 - Image &#8594; <span style="color:#009EDF">*navigationCameraClose*</span> image asset
	 - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.camera.close*</span> localized string
- Help button
	- Image &#8594; <span style="color:#009EDF">*navigationCameraHelp*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.camera.help*</span> localized string

##### 2. Camera preview
- Guides color &#8594;  `GiniConfiguration.cameraPreviewCornerGuidesColor`
- Focus large image &#8594; <span style="color:#009EDF">*cameraFocusLarge*</span> image asset
- Focus large small &#8594; <span style="color:#009EDF">*cameraFocusSmall*</span> image asset
- Opaque view style (when tool tip is shown)  &#8594;  `GiniConfiguration.toolTipOpaqueBackgroundStyle`

##### 3. Camera buttons container
- Capture button
	 - Image &#8594; <span style="color:#009EDF">*cameraCaptureButton*</span> image asset
- Import button
	- Image &#8594; <span style="color:#009EDF">*documentImportButton*</span> image asset
- Captured images stack indicator color &#8594; `GiniConfiguration.imagesStackIndicatorLabelTextcolor`

##### 4. QR code popup
<br>
<center><img src="img/Customization guide/QR code popup.jpg" height="70"/></center>
</br>
- Background color &#8594;  `GiniConfiguration.qrCodePopupBackgroundColor`
- Button color &#8594;  `GiniConfiguration.qrCodePopupButtonColor`
- Text color &#8594;  `GiniConfiguration.qrCodePopupTextColor`
- Title &#8594; <span style="color:#009EDF">*ginivision.camera.qrCodeDetectedPopup.buttonTitle*</span> localized string
- Message &#8594; <span style="color:#009EDF">*ginivision.camera.qrCodeDetectedPopup.message*</span> localized string

## Review screen

<br>
<center><img src="img/Customization guide/Review.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.title*</span> localized string
- Back button
	 - Image &#8594; <span style="color:#009EDF">*navigationReviewBack*</span> image asset
	 - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.back*</span> localized string
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.continue*</span> localized string

##### 2. Review top view
- Title &#8594; <span style="color:#009EDF">*ginivision.review.top*</span> localized string

##### 3. Review bottom view
- Background color &#8594; `GiniConfiguration.reviewBottomViewBackgroundColor`
- Rotation button image &#8594;  <span style="color:#009EDF">*reviewRotateButton*</span> image asset
- Rotation message
	- Text &#8594; <span style="color:#009EDF">*ginivision.review.bottom*</span> localized string
	- Text color &#8594; `GiniConfiguration.reviewTextBottomColor`

## Multipage Review screen

<br>
<center><img src="img/Customization guide/MultipageReview.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Back button
	 - Image &#8594; <span style="color:#009EDF">*navigationReviewBack*</span> image asset
	 - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.back*</span> localized string
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.continue*</span> localized string

##### 2. Main collection
- Opaque view style (when tool tip is shown)  &#8594;  `GiniConfiguration.toolTipOpaqueBackgroundStyle`

##### 3. Page item
- Page indicator color &#8594; `GiniConfiguration.multipagePageIndicatorColor`
- Page background color &#8594; `GiniConfiguration.multipagePageBackgroundColor`

##### 4. Bottom container
- Background color &#8594; `GiniConfiguration.multipagePagesContainerAndToolBarColor`
- Rotation button image &#8594;  <span style="color:#009EDF">*rotateImageIcon*</span> image asset
- Delete button image &#8594;  <span style="color:#009EDF">*trashIcon*</span> image asset

## Analysis screen

<br>
<center><img src="img/Customization guide/Analysis.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Cancel button
	 - Image &#8594; <span style="color:#009EDF">*navigationAnalysisBack*</span> image asset
	 - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.analysis.back*</span> localized string

##### 2. PDF Information view
- Text color &#8594; `GiniConfiguration.analysisPDFInformationTextColor`
- Background color &#8594; `GiniConfiguration.analysisPDFInformationBackgroundColor`

##### 3. Loading view
- Indicator color &#8594; `GiniConfiguration.analysisLoadingIndicatorColor` (Only with PDFs)
- Text &#8594; <span style="color:#009EDF">*ginivision.analysis.loadingText*</span> localized string

## Supported formats screen

<br>
<center><img src="img/Customization guide/Supported formats.jpg" height="500"/></center>
</br>

##### 1. Supported format cells
- Supported formats icon color &#8594; `GiniConfiguration.supportedFormatsIconColor`
- Non supported formats icon color &#8594; `GiniConfiguration.nonSupportedFormatsIconColor`

## Open with tutorial screen

<br>
<center><img src="img/Customization guide/Open with tutorial.jpg" height="500"/></center>
</br>

##### 1. Header
- Text &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.collectionHeader*</span> localized string

##### 2. Open with steps
- App name &#8594; `GiniConfiguration.openWithAppNameForTexts`
- Step indicator color &#8594; `GiniConfiguration.stepIndicatorColor`
- Step 1
	- Title &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step1.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step1.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep1*</span> image asset
- Step 2
	- Title &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step2.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step2.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep2*</span> image asset
- Step 3
	- Title &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step3.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step3.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep3*</span> image asset

## Capturing tips screen

<br>
<center><img src="img/Customization guide/No results.jpg" height="500"/></center>
</br>

##### 1. Capturing tip images
- Tip 1 image &#8594; <span style="color:#009EDF">*captureSuggestion1*</span> image asset
- Tip 2 image &#8594; <span style="color:#009EDF">*captureSuggestion2*</span> image asset
- Tip 3 image &#8594; <span style="color:#009EDF">*captureSuggestion3*</span> image asset
- Tip 4 image &#8594; <span style="color:#009EDF">*captureSuggestion4*</span> image asset
- Tip 5 image &#8594; <span style="color:#009EDF">*captureSuggestion5*</span> image asset

##### 2. Go to camera button
- Background color &#8594; `GiniConfiguration.noResultsBottomButtonColor`

## Gallery album screen

<br>
<center><img src="img/Customization guide/Gallery album.jpg" height="500"/></center>
</br>

##### 1. Selected image
- Selected item check color &#8594; `GiniConfiguration.galleryPickerItemSelectedBackgroundCheckColor`
