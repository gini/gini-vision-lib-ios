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
    
    if (_document) {
        [self sendFeedback:_document];
    }
}

- (void)sendFeedback:(GINIDocument *)document {
    
    // Get current Gini SDK instance to upload image and process exctraction
    GiniSDK *gini = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;
    
    // Get extractions from document
    [[[document.extractions continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error getting extractions from document: %@", document.documentId);
            return nil;
        }
        
        NSMutableDictionary *extractions = task.result;
        
        // Make sure the displayed results are the same as the ones feedback should be given on
        if (_result != extractions) {
            NSLog(@"Error extractions do not relate to the given document: %@", document.documentId);
            return nil;
        }
        
        // As an example will set the BIC value statically.
        // In a real world example the user input should be used as the new value.
        // You should send feedback only for labels which the user has seen. Unseen labels should be filtered out.
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
        GINIDocumentTaskManager *documentTaskManager = gini.documentTaskManager;
        return [documentTaskManager updateDocument:document];
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error sending Feedback");
            return nil;
        }
        
        // For testing purposes we'll get the extractions again to check if feedback was send correctly
        return document.extractions;
    }] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error getting extractions from document: %@", document.documentId);
            return nil;
        }
        
        NSLog(@"extractions updated: %@", (NSDictionary *)task.result);
        
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
