Event Tracking
=============================

The version 5.2 of Gini Vision Library introduces the ability to track user events. In order to receive the events, implement the `GiniVisionTrackingDelegate` protocol and supply the delegate when initializing GVL. For example:

```swift
let viewController = GiniVision.viewController(withClient: client,
                                               importedDocuments: visionDocuments,
                                               configuration: visionConfiguration,
                                               resultsDelegate: self,
                                               documentMetadata: documentMetadata,
                                               trackingDelegate: trackingDelegate)
```

## Events

Event types are partitioned into different domains according to the screens that they appear at. Each domain has a number of event types. Some events may supply additional data in a dictionary. Certain events pertaining to transitions between screens are only reported in the Screen API.

| Domain | Event type | Additional info keys | Comment | Introduced in | Screen API | Compoment API |
| --- | --- | --- | --- | --- | :---: | :---: | 
| Onboarding | `start` || Onboarding started | GVL 5.2 | ✅ | ✅ |
| Onboarding | `finish` || User completed onboarding | GVL 5.2 | ✅ | ✅ |
| Camera Screen | `exit` || User closed the camera screen | GVL 5.2 | ✅ | ❌ |
| Camera Screen | `help` || User tapped "Help" on the camera screen | GVL 5.2 | ✅ | ❌ |
| Camera Screen | `takePicture` || User took a picture | GVL 5.2 | ✅ | ✅ |
| Review Screen | `back` || User went back from the review screen | GVL 5.2 | ✅ | ❌ |
| Review Screen | `next` || User advanced from the review screen | GVL 5.2 | ✅ | ❌ |
| Analysis Screen | `cancel` || User canceled the process during analysis | GVL 5.2 | ✅ | ❌ |
| Analysis Screen | `error` | `"message"` | The analysis ended with an error. The error message is supplied under the "message" key. | GVL 5.2 | ✅ | ✅ |
| Analysis Screen | `retry` || The user decided to retry after an analysis error. | GVL 5.2 | ✅ | ✅ |

## Component API

If you are using the Component API, you may want to implement the remaining events in your coordinator code. In order to report an event, call the `GiniVisionTrackingDelegate` method relating to the event's domain area and pass the event. 

For instance to report user advancing from the Review Screen, call `onReviewScreenEvent(event:)` passing an `Event<ReviewScreenEventType>` struct. `ReviewScreenEventType` defines the event types available in the Review Screen domain.

The call would look something like this:

```swift
trackingDelegate?.onReviewScreenEvent(event: Event(type: .next))
```


