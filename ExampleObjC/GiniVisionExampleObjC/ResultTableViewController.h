//
//  ResultTableViewController.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 12/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Gini_iOS_SDK/GiniSDK.h>

@interface ResultTableViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *result;
@property (nonatomic, strong) GINIDocument *document;

@end
