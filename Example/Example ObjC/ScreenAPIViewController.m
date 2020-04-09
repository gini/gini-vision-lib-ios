//
//  ScreenAPIViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ScreenAPIViewController.h"
#import "ResultTableViewController.h"
#import "NoResultViewController.h"
#import <GiniVision/GiniVision-Swift.h>
#import "CredentialsManager.h"
#import <Example_ObjC-Swift.h>

@interface ScreenAPIViewController () <GiniVisionResultsDelegate>

@property (nonatomic, strong) UIViewController *giniVisionVC;

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
    giniConfiguration.fileImportSupportedTypes = GiniVisionImportFileTypesPdf_and_images;
    giniConfiguration.openWithEnabled = YES;
    giniConfiguration.qrCodeScanningEnabled = YES;
    giniConfiguration.returnAssistantEnabled = YES;
    
    // 2. Create the Gini Vision Library view controller using a bridging Swift file,
    // set a delegate object and pass in the configuration object
    NSDictionary<NSString*, NSString*> *credentials = [[[CredentialsManager alloc] init]
                                                       getCredentials];
    
    self.giniVisionVC = [GVLBridge viewControllerWithClientId:credentials[kClientId]
                                                       secret:credentials[kClientPassword]
                                                       domain:credentials[kClientPassword]
                                            giniConfiguration:giniConfiguration
                                              resultsDelegate:self];
    
    // 3. Present the Gini Vision Library Screen API modally
    [self presentViewController:_giniVisionVC animated:YES completion:nil];
    
    // 4. Handle callbacks send out via the `GINIVisionDelegateResult` to get results or errors.
}

- (void)presentResults:(AnalysisResult *)result
     sendFeedbackBlock:(void (^ _Nonnull)(NSDictionary<NSString *,Extraction *> * _Nonnull))sendFeedbackBlock {
    
    NSArray *payFive = @[@"paymentReference", @"iban", @"bic", @"amountToPay", @"paymentRecipient"];
    BOOL hasPayFive = NO;
    
    for (NSString *key in payFive) {
        if (result.extractions[key]) {
            hasPayFive = YES;
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if (hasPayFive) {
                ResultTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"resultScreen"];
                vc.result = result.extractions;
                vc.sendFeedbackBlock = sendFeedbackBlock;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                NoResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"noResultScreen"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    });
}

// MARK: GiniVisionResultsDelegate

- (void)giniVisionDidCancelAnalysis {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)giniVisionAnalysisDidFinishWithResult:(AnalysisResult * _Nonnull)result
                            sendFeedbackBlock:(void (^ _Nonnull)(NSDictionary<NSString *,Extraction *> * _Nonnull))sendFeedbackBlock {
    
    [self presentResults:result sendFeedbackBlock:sendFeedbackBlock];
}


- (void)giniVisionAnalysisDidFinishWithoutResults:(BOOL)showingNoResultsScreen {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            NoResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"noResultScreen"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    });
}

@end
