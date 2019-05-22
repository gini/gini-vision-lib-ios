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
#import "CredentialsManager.h"

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
    giniConfiguration.fileImportSupportedTypes = GiniVisionImportFileTypesPdf_and_images;
    giniConfiguration.openWithEnabled = YES;
    giniConfiguration.qrCodeScanningEnabled = YES;
    
    // 2. Create the Gini Vision Library view controller, set a delegate object and pass in the configuration object
    UIViewController *vc =  [GiniVision viewControllerWithDelegate:self
                                                 withConfiguration:giniConfiguration
                                                  importedDocument:NULL];
    // 3. Present the Gini Vision Library Screen API modally
    [self presentViewController:vc animated:YES completion:nil];
    
    // 4. Handle callbacks send out via the `GINIVisionDelegate` to get results, errors or updates on other user actions
}

- (void)giniVisionDidCancelAnalysis {
    [self dismissViewControllerAnimated:true completion:nil];
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
        vc.document = _document;
        vc.result = _result;
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

// MARK: Gini Vision delegate

- (void)didCaptureWithDocument:(id<GiniVisionDocument> _Nonnull)document
               networkDelegate:(id<AnalysisDelegate,UploadDelegate> _Nonnull)networkDelegate {
    // When using Multipage, each document must be uploaded and notified to the networkDelegate
    if(document.type != GiniVisionDocumentTypeImage) {
        [self didReviewWithDocuments:@[document] networkDelegate:networkDelegate];
    }
}

- (void)didReviewWithDocuments:(NSArray<id<GiniVisionDocument>> * _Nonnull)documents
               networkDelegate:(id<AnalysisDelegate,UploadDelegate> _Nonnull)networkDelegate {
    _analysisDelegate = networkDelegate;
    _imageData = documents[0].data;
    [self analyzeDocumentWithImageData:documents[0].data];
}

- (void)didCancelCapturing {
    NSLog(@"Screen API canceled capturing");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didCancelReviewFor:(id<GiniVisionDocument> _Nonnull)document {
    NSLog(@"Screen API canceled review");
    
    // Cancel analysis process to avoid unnecessary network calls.
    [self cancelAnalysis];
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
    [[AnalysisManager sharedManager] analyzeDocumentWithImageData:data
                                                    andCompletion:^(NSDictionary *result, GINIDocument * document, NSError *error) {
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
            [self analyzeDocumentWithImageData: self->_imageData];
        }];
    }
}

- (void)showResults {
    if (_analysisDelegate) {
        _analysisDelegate = nil;
        [self presentResults];
    }
}

@end
