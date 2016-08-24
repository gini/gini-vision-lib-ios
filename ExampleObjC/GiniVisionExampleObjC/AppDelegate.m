//
//  AppDelegate.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set up GiniSDK with your credentials.
    GINISDKBuilder *builder = [GINISDKBuilder anonymousUserWithClientID:GINI_CLIENT_ID clientSecret:GINI_CLIENT_SECRET userEmailDomain:@"example.com"];
    self.giniSDK = [builder build];
    
    return YES;
}

@end
