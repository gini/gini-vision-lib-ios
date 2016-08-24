//
//  AppDelegate.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Gini_iOS_SDK/GiniSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// GiniSDK property to have global access to the Gini API.
@property (strong, nonatomic) GiniSDK* giniSDK;

@end

