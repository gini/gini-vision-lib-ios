//
//  ViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ScreenAPIViewController.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ScreenAPIViewController () <GINIVisionDelegate>

@end

@implementation ScreenAPIViewController

- (IBAction)easyLaunchGiniVision:(id)sender {
    
    // Create a custom configuration object
    GINIConfiguration *giniConfiguration = [GINIConfiguration new];
    giniConfiguration.debugModeOn = YES;
    giniConfiguration.navigationBarItemTintColor = [UIColor whiteColor];
    
    // Create the Gini Vision Library view controller and pass in the configuration object
    UIViewController *vc = [GINIVision viewControllerWithDelegate:self withConfiguration:giniConfiguration];
    
    // Present the Gini Vision Library Screen API modally
    [self presentViewController:vc animated:YES completion:nil];
}

// MARK: GiniVision delegate
// Mandatory delegate methods
- (void)didCapture:(NSData *)imageData {
    NSLog(@"Screen API received image data");
}

- (void)didReview:(NSData *)imageData withChanges:(BOOL)changes {
    NSString *changesString = changes ? @"changes" : @"no changes";
    NSLog(@"Screen API received updated image data with %@", changesString);
}

- (void)didCancelCapturing {
    NSLog(@"Screen API canceled capturing.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Optional delegate methods
- (void)didCancelReview {
    NSLog(@"Screen API canceled review.");
}

- (void)didShowAnalysis:(id<GINIAnalysisDelegate>)analysisDelegate {
    NSLog(@"Screen API started analysis screen.");
    
    // Display an error with a custom message and custom action on the analysis screen
    [analysisDelegate displayErrorWithMessage:@"My network error" andAction:^{
        NSLog(@"Try again");
    }];
}

- (void)didCancelAnalysis {
    NSLog(@"Screen API canceled analysis");
}

@end
