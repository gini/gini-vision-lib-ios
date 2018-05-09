//
//  ViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ScreenAPIViewController.h"
#import "AnalysisManager.h"
#import "ResultTableViewController.h"
#import "NoResultViewController.h"
#import <GiniVision/GiniVision-Swift.h>

@interface ScreenAPIViewController () <GiniVisionResultsDelegate> {
    id<AnalysisDelegate> _analysisDelegate;
    NSData *_imageData;
}

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) GINIDocument *document;

@end

@implementation ScreenAPIViewController

// MARK: View life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

// MARK: User actions
- (IBAction)easyLaunchGiniVision:(id)sender {
    
    /************************************************************************
     * CAPTURE IMAGE WITH THE SCREEN API OF THE GINI VISION LIBRARY FOR IOS *
     ************************************************************************/
    
    // 1. Create a custom configuration object
    GiniConfiguration *giniConfiguration = [GiniConfiguration new];
    giniConfiguration.debugModeOn = YES;
    giniConfiguration.navigationBarItemTintColor = [UIColor whiteColor];
    giniConfiguration.multipageEnabled = YES;
    giniConfiguration.fileImportSupportedTypes = GiniVisionImportFileTypesPdf_and_images;
    giniConfiguration.openWithEnabled = YES;
    giniConfiguration.qrCodeScanningEnabled = YES;
    
    GiniClient *client = [[GiniClient alloc] initWithClientId:@"polo" clientSecret:@"loco" clientEmailDomain:@"polasd"];
    // 2. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
    UIViewController *vc = [GiniVision viewControllerWithClient:client
                                              importedDocuments:NULL
                                              giniConfiguration:giniConfiguration
                                              resultsDelegate:self];
    // 3. Present the Gini Vision Library Screen API modally
    [self presentViewController:vc animated:YES completion:nil];
    
    // 4. Handle callbacks send out via the `GINIVisionDelegate` to get results, errors or updates on other user actions
}

- (void)giniVision:(NSArray<id<GiniVisionDocument>> *)documents
 analysisDidCancel:(BOOL)analysisDidCancel {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)giniVision:(NSArray<id<GiniVisionDocument>> *)documents
analysisDidFinishWithNoResults:(BOOL)showingNoResultsScreen {
    if(!showingNoResultsScreen){
        [self presentResults];
    }
}

- (void)giniVision:(NSArray<id<GiniVisionDocument>> *)documents
analysisDidFinishWithResults:(NSDictionary<NSString *,GINIExtraction *> *)results
      sendFeedback:(void (^)(NSDictionary<NSString *,GINIExtraction *> * _Nonnull))sendFeedback {
    _result = results;
    [self presentResults];
}

- (void)presentResults {
    NSArray *payFive = @[@"paymentReference", @"iban", @"bic", @"amountToPay", @"paymentRecipient"];
    BOOL hasPayFive = NO;
    for (NSString *key in payFive) {
        if (_result[key]) {
            hasPayFive = YES;
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:NULL];
    if (hasPayFive) {
        ResultTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"resultScreen"];
        vc.result = _result;
        vc.document = _document;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:NO];
        });
    } else {
        NoResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"noResultScreen"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:vc animated:NO];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
