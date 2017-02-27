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

// MARK: View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*****************************************************************************
     * ONBOARDING SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
     *****************************************************************************/
    
    // (1. If not already done: Create and set a custom configuration object)
    // See `ComponentAPICameraViewController.m` for implementation details.
    
    // 2. Create the onboarding view controller
    _contentController = [[OnboardingViewController alloc] initWithScrollViewDelegate:nil];
    
    // 3. Display the onboarding view controller
    [self displayContent:_contentController];
}

// Displays the content controller inside the container view
- (void)displayContent:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = self.containerView.bounds;
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

// MARK: User actions
- (IBAction)nextPage:(id)sender {
    
    // Scroll the onboarding to the next page.
    [(OnboardingViewController *)_contentController scrollToNextPage:YES];
}

@end
