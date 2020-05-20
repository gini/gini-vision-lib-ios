//
//  ResultTableViewController.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 12/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GiniVision/GiniVision-Swift.h>

typedef void(^SendFeedbackBlock)(NSDictionary<NSString *,Extraction *> * _Nonnull);

/**
 *  Presents a dictionary of results from the analysis process in a table view.
 *  Values from the dictionary will be used as the cells titles and keys as the cells subtitles.
 */
@interface ResultTableViewController : UITableViewController

/**
 *  The result dictionary from the analysis process.
 */
@property (nonatomic, strong) NSDictionary<NSString *, Extraction *> * _Nullable result;

/**
 *  The feedback block
 */
@property (nonatomic, copy) SendFeedbackBlock _Nullable sendFeedbackBlock;

@end
