//
//  ResultTableViewController.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 12/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Gini_iOS_SDK/GiniSDK.h>

/**
 *  Presents a dictionary of results from the analysis process in a table view.
 *  Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
@interface ResultTableViewController : UITableViewController

/**
 *  The result dictionary from the analysis process.
 */
@property (nonatomic, strong) NSDictionary *result;

/**
 *  The document the results have been extracted from.
 *  Can be used for further processing.
 */
@property (nonatomic, strong) GINIDocument *document;

@end
