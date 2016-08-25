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

// MARK: View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*************************************************************************
     * CAMERA SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
     *************************************************************************/
    
    // 1. Create and set a custom configuration object needs to be done once before using any component of the Component API.
    GINIConfiguration *giniConfiguration = [GINIConfiguration new];
    giniConfiguration.debugModeOn = YES;
    [GINIVision setConfiguration:giniConfiguration];
    
    // 2. Create the camera view controller
    _contentController = [[GINICameraViewController alloc] initWithSuccess:^(NSData * _Nonnull imageData) {
        _imageData = imageData;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"showReview" sender:self];
        });
    } failure:^(enum GINICameraError error) {
        NSLog(@"Component API camera view controller received error:\n%ld)", (long)error);
    }];
    
    // 3. Display the camera view controller
    [self displayContent:_contentController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

// Displays the content controller inside the container view
- (void)displayContent:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = self.containerView.bounds;
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

// MARK: User actions
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showReview"]) {
        if (_imageData) {
            ComponentAPIReviewViewController *vc = (ComponentAPIReviewViewController *)segue.destinationViewController;
            vc.imageData = _imageData;
        }
    }
}



@end
