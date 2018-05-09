//
//  CancelationToken.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 18/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "CancelationToken.h"

@implementation CancelationToken

- (void)cancel {
    self.cancel = YES;
}

@end
