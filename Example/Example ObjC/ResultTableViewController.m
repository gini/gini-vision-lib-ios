//
//  ResultTableViewController.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 12/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "ResultTableViewController.h"
#import "AppDelegate.h"
#import <Gini-Swift.h>

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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // If a valid document is set, send feedback on it.
    // This is just to show case how to give feedback using the Gini SDK for iOS.
    // In a real world application feedback should be triggered after the user has evaluated and eventually corrected the extractions.
    [self sendFeedback:self.result];
}

- (void)sendFeedback:(NSDictionary<NSString *, Extraction *> *)result {
    
    /*******************************************
     * SEND FEEDBACK WITH THE GINI SDK FOR IOS *
     *******************************************/
    
    // As an example will set the BIC value statically.
    // In a real world application the user input should be used as the new value.
    // Feedback should only be send for labels which the user has seen. Unseen labels should be filtered out.
    
    NSString *bicValue = @"BYLADEM1001";
    Extraction *bic = result[@"bic"];
    
    NSMutableDictionary *updatedResult = [result mutableCopy];
    
    // Update or add the new value.
    if (bic) {
        bic.value = bicValue;
    } else {
        bic = [[Extraction alloc] initWithBox:nil
                                   candidates:nil
                                       entity:@"bic"
                                        value:bicValue
                                         name:@"bic"];
        updatedResult[@"bic"] = bic;
    }
    // Repeat this step for all altered fields.
    self.sendFeedbackBlock(updatedResult);
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
        
    cell.textLabel.text = _result[key].value;
    cell.detailTextLabel.text = key;
    return cell;
}

@end
