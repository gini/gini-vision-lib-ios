//
//  ComponentAPICameraViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 22/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ComponentAPICameraViewController.h"
#import "ComponentAPIReviewViewController.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ComponentAPICameraViewController () {
    NSData *_imageData;
    UIViewController *_contentController;
}

@property (strong, nonatomic) IBOutlet UIView *containerView;

- (IBAction)back:(id)sender;

@end

@implementation ComponentAPICameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create and set a custom configuration object
    GINIConfiguration *giniConfiguration = [GINIConfiguration new];
    giniConfiguration.debugModeOn = YES;
    [GINIVision setConfiguration:giniConfiguration];
    
    // Create the camera view controller
    _contentController = [[GINICameraViewController alloc] initWithSuccess:^(NSData * _Nonnull imageData) {
        _imageData = imageData;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"showReview" sender:self];
        });
    } failure:^(enum GINICameraError error) {
        NSLog(@"Component API camera view controller received error:\n%ld)", (long)error);
    }];
    
    // Display the camera view controller
    [self displayContent:_contentController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

// Go back to the API selection view controller
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showReview"]) {
        if (_imageData) {
            ComponentAPIReviewViewController *vc = (ComponentAPIReviewViewController *)segue.destinationViewController;
            // Set image data as input for the review view controller
            vc.imageData = _imageData;
        }
    }
}

// Displays the content controller inside the container view
- (void)displayContent:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = self.containerView.bounds;
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

@end
