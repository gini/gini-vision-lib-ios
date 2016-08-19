//
//  ComponentAPIAnalysisViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/07/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ComponentAPIAnalysisViewController.h"
#import "AnalysisManager.h"
#import "ResultTableViewController.h"
#import "NoResultViewController.h"
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
    
    // Subscribe for analysis events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAnalysisErrorNotification:) name:GINIAnalysisManagerDidReceiveErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAnalysisResultNotification:) name:GINIAnalysisManagerDidReceiveResultNotification object:nil];
    
    // Check for already existent results in shared analysis manager
    [self handleExistingResults];
    
    // Starts loading animation
    [(GINIAnalysisViewController *)_contentController showAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Never forget to remove observers when you support iOS versions prior to 9.0
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Handle tap on error button
- (IBAction)errorButtonTapped:(id)sender {
    [(GINIAnalysisViewController *)_contentController showAnimation];
    [self hideErrorButton];
    [[AnalysisManager sharedManager] analyzeDocumentWithImageData:_imageData cancelationToken:[CancelationToken new] andCompletion:nil];
}

- (void)handleExistingResults {
    AnalysisManager *manager = [AnalysisManager sharedManager];
    if (manager.result && manager.document) {
        [self handleAnalysisResult:manager.result fromDocument:manager.document];
    } else if (manager.error) {
        [self handleAnalysisError:manager.error];
    }
}

- (void)handleAnalysisErrorNotification:(NSNotification *)notification {
    NSError *error = (NSError *)notification.userInfo[GINIAnalysisManagerErrorUserInfoKey];
    [self handleAnalysisError:error];
}

- (void)handleAnalysisResultNotification:(NSNotification *)notification {
    NSDictionary *result = (NSDictionary *)notification.userInfo[GINIAnalysisManagerResultDictionaryUserInfoKey];
    GINIDocument *document = (GINIDocument *)notification.userInfo[GINIAnalysisManagerDocumentUserInfoKey];
    if (result && document) {
        [self handleAnalysisResult:result fromDocument:document];
    } else {
        [self handleAnalysisError:nil];
    }
}

- (void)handleAnalysisError:(NSError *)error {
    if (error) {
        NSLog(@"%@", error.description);
    }
    
    // For the sake of simplicity we'll always present a generic error which allows the user to retry the analysis.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayError];
    });
}

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
    
    // Remove analysis screen from navigation stack
    NSMutableArray *navigationStack = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    [navigationStack removeObject:self];
    self.navigationController.viewControllers = navigationStack;
}

// Display a generic error notice
- (void)displayError {
    [(GINIAnalysisViewController *)_contentController hideAnimation];
    [self showErrorButton];
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

@end
