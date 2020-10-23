Customization guide
=============================

The Gini Vision Library components can be customized either through the `GiniConfiguration`, the `Localizable.string` file or through the assets. Here you can find a complete guide with the reference to every customizable item.

- [Generic components](#generic-components)
- [Camera screen](#camera-screen)
- [Review screen](#review-screen)
- [Multipage Review screen](#multipage-review-screen)
- [Analysis screen](#analysis-screen)
- [Digital invoice screen](#digital-invoice-screen)
- [Digital invoice onboarding screen](#digital-invoice-onboarding-screen)
- [Line item details screen](#line-item-details-screen)
- [Return reasons dialog](#return-reasons-dialog)
- [What is this dialog](#what-is-this-dialog)
- [Supported formats screen](#supported-formats-screen)
- [Open with tutorial screen](#open-with-tutorial-screen)
- [Capturing tips screen](#capturing-tips-screen)
- [Gallery album screen](#gallery-album-screen)
- [Onboarding screens](#onboarding-screens)
- [Help screen](#help-screen)



Customizable assets can be found in [the Assets repo](https://github.com/gini/gini-vision-lib-assets).

## Supporting dark mode

Some background and text colors use the `GiniColor` type with which you can set colors for dark and light modes. Please make sure to set contrasting images to the background colors in your `.xcassets` for the Gini Vision Library images you override (e.g. `onboardingPage1`). The text colors should also be set in contrast to the background colors.

## Generic components
 
`GiniConfiguration.backgroundColor` is deprecated in version 5.5.0. Use the screen specific background color instead e.g. `GiniConfiguration.onboardingScreenBackgroundColor`.

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
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationCameraClose*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.camera.close*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarCameraTitleCloseButton`
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
- Flash toggle can be enabled through &#8594; `GiniConfiguration.flashToggleEnabled`
- Flash button
    - Image &#8594; <span style="color:#009EDF">*flashOn*</span> image asset
    - Image &#8594; <span style="color:#009EDF">*flashOff*</span> image asset

##### 4. QR code popup
<br>
<center><img src="img/Customization guide/QR code popup.jpg" height="70"/></center>
</br>
- Background color &#8594;  `GiniConfiguration.qrCodePopupBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Button color &#8594;  `GiniConfiguration.qrCodePopupButtonColor`
- Text color &#8594;  `GiniConfiguration.qrCodePopupTextColor` using `GiniColor` with dark mode and light mode colors
- Title &#8594; <span style="color:#009EDF">*ginivision.camera.qrCodeDetectedPopup.buttonTitle*</span> localized string
- Message &#8594; <span style="color:#009EDF">*ginivision.camera.qrCodeDetectedPopup.message*</span> localized string

## Review screen

<br>
<center><img src="img/Customization guide/Review.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.title*</span> localized string
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationReviewBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.back*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarReviewTitleBackButton`
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
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationReviewBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.back*</span> localized string
  - With title only
	  -  Title &#8594; `GiniConfiguration.navigationBarReviewTitleBackButton`
- Next button
	- Image &#8594; <span style="color:#009EDF">*navigationReviewContinue*</span> image asset
	- Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.review.continue*</span> localized string

##### 2. Main collection
- Opaque view style (when tool tip is shown)  &#8594;  `GiniConfiguration.multipageToolTipOpaqueBackgroundStyle`

##### 3. Page item
- Page circle indicator color &#8594; `GiniConfiguration.indicatorCircleColor` using `GiniColor` with dark mode and light mode colors
- Page indicator color &#8594; `GiniConfiguration.multipagePageIndicatorColor` 
- Page background color &#8594; `GiniConfiguration.multipagePageBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Page selected indicator color &#8594; `GiniConfiguration.multipagePageSelectedIndicatorColor`
- Page draggable icon tint color &#8594; `GiniConfiguration.multipageDraggableIconColor`

##### 4. Bottom container
- Background color &#8594; `GiniConfiguration.multipagePagesContainerAndToolBarColor` using `GiniColor` with dark mode and light mode colors
- Rotation button image &#8594;  <span style="color:#009EDF">*rotateImageIcon*</span> image asset
- Delete button image &#8594;  <span style="color:#009EDF">*trashIcon*</span> image asset

## Analysis screen

<br>
<center><img src="img/Customization guide/Analysis.jpg" height="500"/></center>
</br>

##### 1. Navigation bar
- Cancel button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationAnalysisBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.analysis.back*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarAnalysisTitleBackButton`

##### 2. PDF Information view
- Text color &#8594; `GiniConfiguration.analysisPDFInformationTextColor`
- Background color &#8594; `GiniConfiguration.analysisPDFInformationBackgroundColor`

##### 3. Loading view
- Indicator color &#8594; `GiniConfiguration.analysisLoadingIndicatorColor` (Only with PDFs)
- Text &#8594; <span style="color:#009EDF">*ginivision.analysis.loadingText*</span> localized string

## Digital invoice screen

<br>
<center><img src="img/Customization guide/Digital invoice screen.jpg" height="500"/></center>
</br>

- Background color &#8594; `GiniConfiguration.digitalInvoiceBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 1. Navigation bar
- Title &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.screentitle*</span> localized string

##### 2. Message
- Primary
   - Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.headermessage.primary*</span> localized string
   - Font &#8594; `GiniConfiguration.customFont`
- Secondary
   - Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.headermessage.secondary*</span> localized string
   - Color &#8594; `GiniConfiguration.digitalInvoiceSecondaryMessageTextColor`
   - Font &#8594; `GiniConfiguration.digitalInvoiceSecondaryMessageTextFont `

##### 3. Illustration
- Image &#8594; <span style="color:#009EDF">*invoiceIllustration*</span> image asset

##### 4. Selected and total items
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.items*</span> localized formatted string with two `%d` placeholders
- Font &#8594; `GiniConfiguration.digitalInvoiceItemsSectionHeaderTextFont`

##### 5. "What is this?" button
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.whatisthisbutton*</span> localized string
- Font &#8594; `GiniConfiguration.digitalInvoiceItemsSectionHeaderTextFont`
- Image &#8594; <span style="color:#009EDF">*infoIcon*</span> image asset
- Tint color &#8594; `GiniConfiguration.lineItemTintColor`

##### 6. Line item cell
- Background color &#8594; `GiniConfiguration.digitalInvoiceLineItemsBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Tint color &#8594; `GiniConfiguration.lineItemTintColor`
- Name
   - Font &#8594; `GiniConfiguration.digitalInvoiceLineItemNameFont`
- Edit button
   - Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.editbutton*</span> localized string
   - Font &#8594; `GiniConfiguration.digitalInvoiceLineItemEditButtonTitleFont`
   - Image &#8594; <span style="color:#009EDF">*editIcon*</span> image asset
- Quantity or return reason
   - Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.quantity*</span> localized formatted string with one `%d` placeholder
   - Font &#8594; `GiniConfiguration.digitalInvoiceLineItemQuantityOrReturnReasonFont`
- Price
   - Main Unit
      - Font &#8594; `GiniConfiguration.digitalInvoiceLineItemPriceMainUnitFont`
   - Fractional Unit
      - Font &#8594; `GiniConfiguration.digitalInvoiceLineItemPriceFractionalUnitFont`
  
##### 7. Discounts or additional costs (addons)
- Label
   - Font &#8594; `GiniConfiguration.digitalInvoiceAddonLabelFont`
- Price
   - Color &#8594; `GiniConfiguration.digitalInvoiceAddonPriceColor`
   - Main Unit
      - Font &#8594; `GiniConfiguration.digitalInvoiceLineItemPriceMainUnitFont`   
   - Fractional Unit
      - Font &#8594; `GiniConfiguration.digitalInvoiceAddonPriceFractionalUnitFont`

##### 8. Total price
- Color &#8594; `GiniConfiguration.digitalInvoiceTotalPriceColor`
- Main Unit
   - Font &#8594; `GiniConfiguration.digitalInvoiceTotalPriceMainUnitFont`   
- Fractional Unit
   - Font &#8594; `GiniConfiguration.digitalInvoiceTotalPriceFractionalUnitFont`

##### 9. Footer message
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.footermessage*</span> localized string
- Font &#8594; `GiniConfiguration.digitalInvoiceFooterMessageTextFont`

##### 10. Pay button
- Background color &#8594; `GiniConfiguration.payButtonBackgroundColor`
- Title color &#8594; `GiniConfiguration.payButtonTitleTextColor`
- Font &#8594; `GiniConfiguration.payButtonTitleFont`

## Digital invoice onboarding screen
<br>
<center><img src="img/Customization guide/Digital invoice onboarding screen.png" height="500"/></center>
</br>

- Background color &#8594; `GiniConfiguration.digitalInvoiceOnboardingBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Text color &#8594; `GiniConfiguration.digitalInvoiceOnboardingTextColor` using `GiniColor` with dark mode and light mode colors
- Font &#8594; `GiniConfiguration.digitalInvoiceOnboardingTextFont`
##### 1. Top icon
- Image &#8594; <span style="color:#009EDF">*digital_invoice_onboarding_icon*</span>  image asset

##### 2. New badge
- Image &#8594; <span style="color:#009EDF">*digital_invoice_onboarding_new_badge*</span> localized image asset

##### 3. First label 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.onboarding.text1*</span> localized string
- Text color &#8594; `GiniConfiguration.digitalInvoiceOnboardingTextColor` using `GiniColor` with dark mode and light mode colors
- Font &#8594; `GiniConfiguration.digitalInvoiceOnboardingTextFont`

##### 4. Help item
- Image &#8594; <span style="color:#009EDF">*digital_invoice_onboarding_item_help*</span> localized image asset

##### 5. Second label 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.onboarding.text2*</span> localized string
- Text color &#8594; `GiniConfiguration.digitalInvoiceOnboardingTextColor` using `GiniColor` with dark mode and light mode colors
- Font &#8594; `GiniConfiguration.digitalInvoiceOnboardingTextFont`

##### 6. Done button

- Color &#8594; `GiniConfiguration.digitalInvoiceOnboardingDoneButtonBackgroundColor` using `GiniColor` with dark mode and light mode colors

- Title color &#8594; `GiniConfiguration.digitalInvoiceOnboardingDoneButtonTextColor` using `GiniColor` with dark mode and light mode colors

- Title font &#8594; `GiniConfiguration.digitalInvoiceOnboardingDoneButtonTextFont`

- Title &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.onboarding.donebutton*</span> localized string

## Line item details screen
<br>
<center><img src="img/Customization guide/Line item details.jpg" height="500"/></center>
</br>

- Background color &#8594; `GiniConfiguration.lineItemDetailsBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### 1. Save button 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.savebutton*</span> localized string

##### 2. Check box button
- Color &#8594; `GiniConfiguration.lineItemTintColor`

##### 3. Item name field
- Description label
	- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.itemnametextfieldtitle*</span> localized string
	- Font &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelColor`
- Text
	- Font &#8594; `GiniConfiguration.lineItemDetailsContentLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsContentLabelColor`

##### 4. Quantity field
- Description label
	- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.quantitytextfieldtitle*</span> localized string
	- Font &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelColor`
- Text
	- Font &#8594; `GiniConfiguration.lineItemDetailsContentLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsContentLabelColor`
- Multiplication label
	- Font &#8594; `GiniConfiguration.lineItemDetailsContentLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsContentLabelColor`


##### 5. Item price field
- Description label
	- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.pricetextfieldtitle*</span> localized string
	- Font &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelColor`
- Text
	- Font &#8594; `GiniConfiguration.lineItemDetailsContentLabelFont`
	- Color &#8594; `GiniConfiguration.lineItemDetailsContentLabelColor`

##### 6. Total price label
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.lineitem.totalpricetitle*</span> localized string
- Font &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelFont`
- Color &#8594; `GiniConfiguration.lineItemDetailsDescriptionLabelColor`

## Return reasons dialog
<br>
<center><img src="img/Customization guide/Return reasons.jpg" height="500"/></center>
</br>

##### 1. Dialog Title
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.deselectreasonactionsheet.message*</span> localized string

##### 2. Return reasons list
- Text is received from the Gini API and is localized for German and English.

##### 3. Cancel action title 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.deselectreasonactionsheet.action.cancel*</span> localized string


## What is this dialog
<br>
<center><img src="img/Customization guide/What is this dialog.jpg" height="500"/></center>
</br>

##### 1. Dialog Title 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.whatisthisactionsheet.title*</span> localized string

##### 2. Message
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.whatisthisactionsheet.message*</span> localized string

##### 3. Helpful action title 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.whatisthisactionsheet.action.helpful*</span> localized string

##### 4. Not helpful action title 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.whatisthisactionsheet.action.nothelpful*</span> localized string

##### 5. Cancel action title 
- Text &#8594; <span style="color:#009EDF">*ginivision.digitalinvoice.whatisthisactionsheet.action.cancel*</span> localized string

## Supported formats screen

<br>
<center><img src="img/Customization guide/Supported formats.jpg" height="500"/></center>
</br>

##### Navigation bar
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*arrowBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.help.backToMenu*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarHelpScreenTitleBackToMenuButton`

##### 1. Supported format cells
- Supported formats icon color &#8594; `GiniConfiguration.supportedFormatsIconColor`
- Non supported formats icon color &#8594; `GiniConfiguration.nonSupportedFormatsIconColor`

## Open with tutorial screen

<br>
<center><img src="img/Customization guide/Open with tutorial.jpg" height="500"/></center>
</br>

##### Navigation bar
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*arrowBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.help.backToMenu*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarHelpScreenTitleBackToMenuButton`

##### 1. Header
- Text &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.collectionHeader*</span> localized string

##### 2. Open with steps
- App name &#8594; `GiniConfiguration.openWithAppNameForTexts`
- Step indicator color &#8594; `GiniConfiguration.stepIndicatorColor`
- Step 1
	- Title &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step1.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step1.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep1* (German) and *openWithTutorialStep1_en* (English)</span> image assets
- Step 2
	- Title &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step2.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step2.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep2* (German) and *openWithTutorialStep2_en* (English)</span> image assets
- Step 3
	- Title &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step3.title*</span> localized string
	- Subtitle &#8594; <span style="color:#009EDF">*ginivision.help.openWithTutorial.step3.subtitle*</span> localized string
	- Image &#8594; <span style="color:#009EDF">*openWithTutorialStep3* (German) and *openWithTutorialStep3_en* (English)</span> image assets

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
- Background color &#8594; `GiniConfiguration.galleryScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

## Onboarding screens

<br>
<center><img src="img/Customization guide/Onboarding.jpeg" height="500"/></center>
</br>

- Background color &#8594; `GiniConfiguration.onboardingScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors
- Text color &#8594; `GiniConfiguration.onboardingTextColor` using `GiniColor` with dark mode and light mode colors
- Page indicator color &#8594; `GiniConfiguration.onboardingPageIndicatorColor` using `GiniColor` with dark mode and light mode colors
- Current page indicator color &#8594; `GiniConfiguration.onboardingCurrentPageIndicatorColor` using `GiniColor` with dark mode and light mode colors
- Current page indicator alpha &#8594; `GiniConfiguration.onboardingCurrentPageIndicatorAlpha` sets alpha to the `GiniConfiguration.onboardingCurrentPageIndicatorColor`



## Help screen

<br>
<center><img src="img/Customization guide/Help screen.jpeg" height="500"/></center>
</br>

- Background color &#8594; `GiniConfiguration.helpScreenBackgroundColor` using `GiniColor` with dark mode and light mode colors

##### Navigation bar
- Back button
  - With image and title
	  - Image &#8594; <span style="color:#009EDF">*navigationHelpBack*</span> image asset
	  - Title &#8594; <span style="color:#009EDF">*ginivision.navigationbar.help.backToCamera*</span> localized string
  - With title only
	  - Title &#8594; `GiniConfiguration.navigationBarHelpMenuTitleBackToCameraButton`

##### Table View Cells
- Cell background color &#8594; `GiniConfiguration.helpScreenCellsBackgroundColor` using `GiniColor` with dark mode and light mode colors
