//
//  CancelationToken.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Simple cancelation token implementation. 
 *  Used in asychronous tasks.
 */
@interface CancelationToken : NSObject

/**
 *  Cancel propoerty to check the current cancelled state of the object.
 */
@property (nonatomic, assign, getter=cancelled) BOOL cancel;

/**
 *  Sets the state of the token to cancelled.
 */
- (void)cancel;

@end
