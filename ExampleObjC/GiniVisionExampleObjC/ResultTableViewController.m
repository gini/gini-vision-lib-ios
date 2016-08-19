//
//  ResultTableViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 12/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ResultTableViewController.h"
#import "AppDelegate.h"

@interface ResultTableViewController () {
    NSArray *_sortedKeys;
}

@end

@implementation ResultTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_result) {
        _sortedKeys = [[_result allKeys] sortedArrayUsingSelector: @selector(compare:)];
    }
    
    // If a valid document is set, send feedback on it.
    // This is just to show case how to give feedback using the Gini SDK for iOS.
    // In a real world application feedback should be triggered after the user has evaluated and eventually corrected the extractions.
    if (_document) {
        [self sendFeedback:_document];
    }
}

/**
 *  Exemplary method to send feedback to the Gini API using the Gini SDK for iOS.
 *
 *  @param document The document feedback should be given on.
 */
- (void)sendFeedback:(GINIDocument *)document {
    
    /*******************************************
     * SEND FEEDBACK WITH THE GINI SDK FOR IOS *
     *******************************************/
    
    // Get current Gini SDK instance to upload image and process exctraction
    GiniSDK *sdk = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;
    
    // 1. Get session
    [[[[[[sdk.sessionManager getSession] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return [sdk.sessionManager logIn];
        }
        return task.result;
    
    // 2. Get extractions from the document
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return document.extractions;
        
    // 3. Create and send feedback on the document
    }] continueWithSuccessBlock:^id(BFTask *task) {
        NSMutableDictionary *extractions = task.result;
        
        // As an example will set the BIC value statically.
        // In a real world application the user input should be used as the new value.
        // Feedback should only be send for labels which the user has seen. Unseen labels should be filtered out.
        
        NSString *bicValue = @"BYLADEM1001";
        GINIExtraction *bic = (GINIExtraction *)extractions[@"bic"];
        
        // Update or add the new value
        if (bic) {
            bic.value = bicValue;
        } else {
            bic = [[GINIExtraction alloc] initWithName:@"bic" value:bicValue entity:@"bic" box:nil];
            extractions[@"bic"] = bic;
        }
        // Repeat this step for all altered fields.
        
        // Get the document task manager and send feedback by updating the document.
        GINIDocumentTaskManager *documentTaskManager = sdk.documentTaskManager;
        return [documentTaskManager updateDocument:document];
        
    // 4. Check if feedback was send successfully (only for testing purposes)
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return document.extractions;
        
    // 5. Handle results
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error sending feedback for document with id: %@", document.documentId);
            return nil;
        }
        
        NSLog(@"Upated extractions:\n%@", (NSDictionary *)task.result);
        return  nil;
    }];
}

// MARK: Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _result.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
    NSString *key = _sortedKeys[indexPath.row];
    cell.textLabel.text = ((GINIExtraction *)_result[key]).value;
    cell.detailTextLabel.text = key;
    return cell;
}

@end
