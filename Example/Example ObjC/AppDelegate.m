//
//  AppDelegate.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "AppDelegate.h"
#import <GiniVision/GiniVision-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"Gini Vision Library for iOS (%@)", [GiniVision versionString]);
    
    return YES;
}

@end
