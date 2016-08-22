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

@end

@implementation ComponentAPIReviewViewController

// MARK: View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Save image data for future reference
    _originalData = _imageData;
    
    // Analogouse to the Screen API the image data should be analyzed right away with the Gini SDK for iOS
    // to have results in as early as possible.
    [[AnalysisManager sharedManager] analyzeDocumentWithImageData:_imageData cancelationToken:[CancelationToken new] andCompletion:nil];
    
    /*************************************************************************
     * REVIEW SCREEN OF THE COMPONENT API OF THE GINI VISION LIBRARY FOR IOS *
     *************************************************************************/
    
    // (1. If not already done: Create and set a custom configuration object)
    // See `ComponentAPICameraViewController.m` for implementation details.
    
    // 2. Create the review view controller
    _contentController = [[GINIReviewViewController alloc] init:_imageData success:^(NSData * _Nonnull imageData)
        {
            NSLog(@"Component API review view controller received image data");
            // Update current image data when image is rotated by user
            _imageData = imageData;
        } failure:^(enum GINIReviewError error) {
            NSLog(@"Component API review view controller received error:\n%ld)", (long)error);
        }];
    
    // 3. Display the review view controller
    [self displayContent:_contentController];
}

-(void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    
    // Cancel analysis process to avoid unnecessary network calls.
    if (!parent) {
        [[AnalysisManager sharedManager] cancelAnalysis];
    }
}

// Displays the content controller inside the container view
- (void)displayContent:(UIViewController *)controller {
    [self addChildViewController:controller];
    controller.view.frame = self.containerView.bounds;
    [self.containerView addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

// MARK: User actions
- (IBAction)showAnalysis:(id)sender {
    
    // Analyze reviewed data because changes were made by the user during review.
    if (_imageData != _originalData) {
        _originalData = _imageData;
        [[AnalysisManager sharedManager] analyzeDocumentWithImageData:_imageData cancelationToken:[CancelationToken new] andCompletion:nil];
        [self performSegueWithIdentifier:@"showAnalysis" sender:self];
        return;
    }
    
    NSDictionary *result = [[AnalysisManager sharedManager] result];
    GINIDocument *document = [[AnalysisManager sharedManager] document];
    
    // Present already existing results retrieved from the first analysis process initiated in `viewDidLoad`.
    if (result && document) {
        [self handleAnalysisResult:result fromDocument:document];
        return;
    }
    
    // Restart analysis if it was canceled and is currently not running.
    if (![[AnalysisManager sharedManager] isAnalyzing]) {
        [[AnalysisManager sharedManager] analyzeDocumentWithImageData:_imageData cancelationToken:[CancelationToken new] andCompletion:nil];
    }
    
    // Show analysis screen if no results are in yet and no changes were made.
    [self performSegueWithIdentifier:@"showAnalysis" sender:self];
}

// MARK: Handle results from analysis process
- (void)handleAnalysisResult:(NSDictionary *)result fromDocument:(GINIDocument *)document {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    NSArray *payFive = @[@"paymentReference", @"iban", @"bic", @"amountToPay", @"paymentRecipient"];
    BOOL hasPayFive = NO;
    for (NSString *key in payFive) {
        if (result[key]) {
            hasPayFive = YES;
            break;
        }
    }
    
    if (hasPayFive) {
        ResultTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"resultScreen"];
        vc.result = result;
        vc.document = document;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NoResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"noResultScreen"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// MARK: Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAnalysis"]) {
        if (_imageData) {
            ComponentAPIAnalysisViewController *vc = (ComponentAPIAnalysisViewController *)segue.destinationViewController;
            vc.imageData = _imageData;
        }
    }
}

@end
