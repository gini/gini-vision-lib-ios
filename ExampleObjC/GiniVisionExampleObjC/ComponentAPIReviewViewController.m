//
//  ComponentAPIReviewViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ComponentAPIReviewViewController.h"
#import "ComponentAPIAnalysisViewController.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ComponentAPIReviewViewController () {
    UIViewController *_contentController;
}

@property (strong, nonatomic) IBOutlet UIView *containerView;

- (IBAction)back:(id)sender;

@end

@implementation ComponentAPIReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the review view controller
    _contentController = [[GINIReviewViewController alloc] init:_imageData success:^(NSData * _Nonnull imageData)
        {
            NSLog(@"Component API review view controller received image data.");
            // Update current image data when image is rotated by user
            _imageData = imageData;
        } failure:^(enum GINIReviewError error) {
            NSLog(@"Component API review view controller received error:\n%ld)", (long)error);
        }];
    
    // Display the review view controller
    [self displayContent:_contentController];
}

// Pops back to the camera view controller
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"giniShowAnalysis"]) {
        if (_imageData) {
            ComponentAPIAnalysisViewController *vc = (ComponentAPIAnalysisViewController *)segue.destinationViewController;
            // Set image data as input for the analysis view controller
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
