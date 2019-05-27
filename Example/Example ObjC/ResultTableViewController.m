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

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // If a valid document is set, send feedback on it.
    // This is just to show case how to give feedback using the Gini SDK for iOS.
    // In a real world application feedback should be triggered after the user has evaluated and eventually corrected the extractions.
    _sendFeedback(_result);
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
