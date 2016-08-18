//
//  CancelationToken.h
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CancelationToken : NSObject

- (void)cancel;

@property (nonatomic, assign, getter=cancelled) BOOL cancel;

@end
