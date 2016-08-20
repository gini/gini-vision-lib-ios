//
//  ComponentAPIAnalysisViewController.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  View controller showing how to implement the analysis screen using the Component API of the Gini Vision Library for iOS and
 *  how to process the previously reviewed image using the Gini SDK for iOS
 */
@interface ComponentAPIAnalysisViewController : UIViewController


/**
 *  The image data of the reviewed document to be analyzed.
 */
@property (strong, nonatomic) NSData *imageData;

@end
