Event Tracking
=============================

The version 5.2 of Gini Vision Library introduces the ability to track user events in the Screen API. In order to receive the events, implement the `GiniVisionTrackingDelegate` protocol and supply the delegate when initializing GVL. For example:

```swift
let viewController = GiniVision.viewController(withClient: client,
                                               importedDocuments: visionDocuments,
                                               configuration: visionConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata,
                                               trackingDelegate: trackingDelegate)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types. Some events may supply additional data in a dictionary.

| Domain | Event type | Additional info keys | Comment | Introduced in |
| --- | --- | --- | --- | --- |
| Onboarding | `start` || Onboarding started | GVL 5.2 |
| Onboarding | `finish` || User completes onboarding | GVL 5.2 |
| Camera Screen | `exit` || User closes the camera screen | GVL 5.2 |
| Camera Screen | `help` || User taps "Help" on the camera screen | GVL 5.2 |
| Camera Screen | `takePicture` || User takes picture | GVL 5.2 |
| Review Screen | `back` || User goes back from the review screen | GVL 5.2 |
| Review Screen | `next` || User advances from the review screen | GVL 5.2 |
| Analysis Screen | `cancel` || User cancels the process during analysis | GVL 5.2 |
| Analysis Screen | `error` | `"message"` | The analysis ended with an error. The error message is supplied under the "message" key. | GVL 5.2 |
| Analysis Screen | `retry` || The user decides to retry after an analysis error. | GVL 5.2 |
