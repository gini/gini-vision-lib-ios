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
#import <GiniVision/GiniVision-Swift.h>

@interface ScreenAPIViewController () <GINIVisionDelegate> {
    id<GINIAnalysisDelegate> _analysisDelegate;
    NSData *_imageData;
    AnalysisManager *_analysisManager;
}

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) GINIDocument *document;

@end

@implementation ScreenAPIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (IBAction)easyLaunchGiniVision:(id)sender {
    
    // Create a custom configuration object
    GINIConfiguration *giniConfiguration = [GINIConfiguration new];
    giniConfiguration.debugModeOn = YES;
    giniConfiguration.navigationBarItemTintColor = [UIColor whiteColor];
    
    // Create the Gini Vision Library view controller and pass in the configuration object
    UIViewController *vc = [GINIVision viewControllerWithDelegate:self withConfiguration:giniConfiguration];
    
    // Present the Gini Vision Library Screen API modally
    [self presentViewController:vc animated:YES completion:nil];
}

// MARK: Handle analysis of document

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
    // Check for at least 1 pay five element else show no results screen
    NSArray *payFive = @[@"iban", @"bic", @"amountToPay", @"paymentReference", @"paymentRecipient"];
    NSString *segueIdentifier = @"presentNoResult";
    for (NSString *key in payFive) {
        if (_result[key]) {
            segueIdentifier = @"presentResult";
            break;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"FINISHED WITH RESULT\n%@", self.result);
            [self performSegueWithIdentifier:segueIdentifier sender:self];
        }];
    });
}

- (void)analyzeDocumentWithImageData:(NSData *)data {
    [self cancelAnalysis];
    _imageData = data;
    _analysisManager = [AnalysisManager new];
    [_analysisManager analyzeDocumentWithImageData:data andCompletion:^(NSDictionary *result, GINIDocument * document, NSError *error) {
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
    if (_analysisManager) {
        [_analysisManager cancel];
        _analysisManager = nil;
    }
    _result = nil;
    _document = nil;
    _errorMessage = nil;
    _imageData = nil;
}

// MARK: Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"presentResult"]) {
        ResultTableViewController *vc = (ResultTableViewController *)segue.destinationViewController;
        vc.document = _document;
        vc.result = _result;
    }
}


// MARK: GiniVision delegate
// Mandatory delegate methods
- (void)didCapture:(NSData *)imageData {
    NSLog(@"Screen API received image data");
    
    // Send original image data to analysis to have the results in as early as possible
    [self analyzeDocumentWithImageData:imageData];
}

- (void)didReview:(NSData *)imageData withChanges:(BOOL)changes {
    NSString *changesString = changes ? @"changes" : @"no changes";
    NSLog(@"Screen API received updated image data with %@", changesString);
    
    // Changes were made to the document so the new data needs to be analyzed
    if (changes) {
        [self analyzeDocumentWithImageData:imageData];
        return;
    }
    
    // No changes were made and their is already a result from the original data - Great!
    if (_result && _document) {
        [self presentResults];
    }
}

- (void)didCancelCapturing {
    NSLog(@"Screen API canceled capturing.");
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Optional delegate methods
- (void)didCancelReview {
    NSLog(@"Screen API canceled review.");
    
    // Cancel analysis process to avoid unnecessary network calls
    [self cancelAnalysis];
}

- (void)didShowAnalysis:(id<GINIAnalysisDelegate>)analysisDelegate {
    NSLog(@"Screen API started analysis screen.");
    
    _analysisDelegate = analysisDelegate;
    
    // Show error message which may already occured while document was still reviewed
    [self showErrorMessage];
}

- (void)didCancelAnalysis {
    NSLog(@"Screen API canceled analysis");
    
    // Cancel analysis process to avoid unnecessary network calls
    [self cancelAnalysis];
    
    // Reset analysis delegate
    _analysisDelegate = nil;
}

@end
