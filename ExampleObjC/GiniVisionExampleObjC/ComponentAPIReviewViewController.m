//
//  ComponentAPIReviewViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ComponentAPIReviewViewController.h"
#import "ComponentAPIAnalysisViewController.h"
#import "ResultTableViewController.h"
#import "NoResultViewController.h"
#import "AnalysisManager.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ComponentAPIReviewViewController () {
    UIViewController *_contentController;
    NSData *_originalData;
}

@property (strong, nonatomic) IBOutlet UIView *containerView;

- (IBAction)back:(id)sender;

@end

@implementation ComponentAPIReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Save image data for future reference
    _originalData = _imageData;
    
    // Start uploading initial image data to have the results in as fast as possible
    [[AnalysisManager sharedManager] analyzeDocumentWithImageData:_imageData cancelationToken:[CancelationToken new] andCompletion:nil];
    
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

- (IBAction)showAnalysis:(id)sender {
    if (_imageData != _originalData) {
        _originalData = _imageData;
        
        // Start analysis with updated image data, this will automatically cancel the old analysis process.
        [[AnalysisManager sharedManager] analyzeDocumentWithImageData:_imageData cancelationToken:[CancelationToken new] andCompletion:nil];
        [self performSegueWithIdentifier:@"showAnalysis" sender:self];
        return;
    }
    
    NSDictionary *result = [[AnalysisManager sharedManager] result];
    if (!result) {
        [self performSegueWithIdentifier:@"showAnalysis" sender:self];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    NSArray *payFive = @[@"paymentReference", @"iban", @"bic", @"amountToPay", @"paymentRecipient"];
    for (NSString *key in payFive) {
        if (result[key]) {
            ResultTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"resultScreen"];
            vc.result = result;
            vc.document = [[AnalysisManager sharedManager] document];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
    }
    
    NoResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"noResultScreen"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAnalysis"]) {
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
