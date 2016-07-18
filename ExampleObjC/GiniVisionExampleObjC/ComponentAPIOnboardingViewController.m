//
//  ComponentAPIOnboardingViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 07/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ComponentAPIOnboardingViewController.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ComponentAPIOnboardingViewController () <UIScrollViewDelegate> {
    UIViewController *_contentController;
}

@property (strong, nonatomic) IBOutlet UIView *containerView;

- (IBAction)nextPage:(id)sender;

@end

@implementation ComponentAPIOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the onboarding view controller
    _contentController = [[GINIOnboardingViewController alloc] initWithScrollViewDelegate:nil];
    
    // Display the onboarding view controller
    [self displayContent:_contentController];
}

// Scrolls the onboarding view controller to the next page
- (IBAction)nextPage:(id)sender {
    [(GINIOnboardingViewController *)_contentController scrollToNextPage:YES];
}

// Displays the content controller inside the container view
- (void)displayContent:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = self.containerView.bounds;
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

@end
