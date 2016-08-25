//
//  ComponentAPIReviewViewController.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  View controller showing how to implement the review screen using the Component API of the Gini Vision Library for iOS and
 *  how to process the previously captured image using the Gini SDK for iOS
 */
@interface ComponentAPIReviewViewController : UIViewController

/**
 *  The image data of the captured document to be reviewed.
 */
@property (strong, nonatomic) NSData *imageData;

@end
