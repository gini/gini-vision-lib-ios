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

@interface ScreenAPIViewController () <GiniVisionDelegate> {
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
    
    // 2. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
    UIViewController *vc = [GiniVision viewControllerWithDelegate:self withConfiguration:giniConfiguration];
    
    // 3. Present the Gini Vision Library Screen API modally
    [self presentViewController:vc animated:YES completion:nil];
    
    // 4. Handle callbacks send out via the `GINIVisionDelegate` to get results, errors or updates on other user actions
}

// MARK: Gini Vision delegate
- (void)didCapture:(NSData *)imageData {
    NSLog(@"Screen API received image data");
    
    // Analyze image data right away with the Gini SDK for iOS to have results in as early as possible.
    [self analyzeDocumentWithImageData:imageData];
}

- (void)didReview:(NSData *)imageData withChanges:(BOOL)changes {
    NSString *changesString = changes ? @"changes" : @"no changes";
    NSLog(@"Screen API received updated image data with %@", changesString);
    
    // Analyze reviewed data because changes were made by the user during review.
    if (changes) {
        [self analyzeDocumentWithImageData:imageData];
        return;
    }
    
    // Present already existing results retrieved from the first analysis process initiated in `didCapture:`.
    if (_result && _document) {
        [self presentResults];
        return;
    }
    
    // Restart analysis if it was canceled and is currently not running.
    if (![[AnalysisManager sharedManager] isAnalyzing]) {
        [self analyzeDocumentWithImageData:imageData];
    }
}

- (void)didCancelCapturing {
    NSLog(@"Screen API canceled capturing");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelReview {
    NSLog(@"Screen API canceled review");
    
    // Cancel analysis process to avoid unnecessary network calls.
    [self cancelAnalysis];
}

- (void)didShowAnalysis:(id<AnalysisDelegate>)analysisDelegate {
    NSLog(@"Screen API started analysis screen");
    
    _analysisDelegate = analysisDelegate;
    
    // The analysis screen is where the user should be confronted with any errors occuring during the analysis process.
    // Show any errors that occured while the user was still reviewing the image here.
    // Make sure to only show errors relevant to the user.
    [self showErrorMessage];
}

- (void)didCancelAnalysis {
    NSLog(@"Screen API canceled analysis");
    
    _analysisDelegate = nil;
    
    // Cancel analysis process to avoid unnecessary network calls.
    [self cancelAnalysis];
}

// MARK: Handle analysis of document
- (void)analyzeDocumentWithImageData:(NSData *)data {
    [self cancelAnalysis];
    _imageData = data;
    [[AnalysisManager sharedManager] analyzeDocumentWithImageData:data cancelationToken:[CancelationToken new] andCompletion:^(NSDictionary *result, GINIDocument * document, NSError *error) {
        if (error) {
            self.errorMessage = @"Es ist ein Fehler aufgetreten. Wiederholen";
        } else if (result && document) {
            self.document = document;
            self.result = result;
        } else {
            self.errorMessage = @"Ein unbekannter Fehler ist aufgetreten. Wiederholen";
        }
    }];
}

- (void)cancelAnalysis {
    [[AnalysisManager sharedManager] cancelAnalysis];
    _result = nil;
    _document = nil;
    _errorMessage = nil;
    _imageData = nil;
}

// MARK: Handle results from analysis process
- (void)setErrorMessage:(NSString *)errorMessage {
    _errorMessage = errorMessage;
    if (_errorMessage) {
        [self showErrorMessage];
    }
}

- (void)setResult:(NSDictionary *)result {
    _result = result;
    if (_result && _document) {
        [self showResults];
    }
}

- (void)showErrorMessage {
    if (_errorMessage && _imageData && _analysisDelegate) {
        [_analysisDelegate displayErrorWithMessage:_errorMessage andAction:^{
            [self analyzeDocumentWithImageData: _imageData];
        }];
    }
}

- (void)showResults {
    if (_analysisDelegate) {
        _analysisDelegate = nil;
        [self presentResults];
    }
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
