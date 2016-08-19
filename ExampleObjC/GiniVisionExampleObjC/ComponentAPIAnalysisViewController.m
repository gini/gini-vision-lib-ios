//
//  ComponentAPIAnalysisViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ComponentAPIAnalysisViewController.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ComponentAPIAnalysisViewController () {
    UIViewController *_contentController;
}

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *errorButton;

- (IBAction)errorButtonTapped:(id)sender;

@end

@implementation ComponentAPIAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide error button on load
    self.errorButton.alpha = 0.0;
    
    // Create the analysis view controller
    _contentController = [[GINIAnalysisViewController alloc] init:_imageData];
    
    // Display the analysis view controller
    [self displayContent:_contentController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Starts loading animation
    [(GINIAnalysisViewController *)_contentController showAnimation];
    
    [self displayError];
}

// Handle tap on error button
- (IBAction)errorButtonTapped:(id)sender {
    [(GINIAnalysisViewController *)_contentController showAnimation];
    [self hideErrorButton];
    [self displayError];
}

// Display a random error notice
- (void)displayError {
    [self delay:1.5 block:^{
        [(GINIAnalysisViewController *)_contentController hideAnimation];
        [self showErrorButton];
    }];
}

// MARK: Toggle error button
- (void)showErrorButton {
    if (_errorButton.alpha == 1.0) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.errorButton.alpha = 1.0;
    }];
}

- (void)hideErrorButton {
    if (_errorButton.alpha == 0.0) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.errorButton.alpha = 0.0;
    }];
}

// Displays the content controller inside the container view
- (void)displayContent:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = self.containerView.bounds;
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

// Little delay helper by @matt rewritten for Objective-C
- (void)delay:(double)delay block:(void(^)())block {
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * (double)NSEC_PER_SEC));
    dispatch_after(after, dispatch_get_main_queue(), block);
}




@end
