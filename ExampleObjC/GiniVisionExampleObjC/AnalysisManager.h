//
//  AnalysisManager.h
//  GiniVisionExampleObjC
//
//  Created by Gini on 11/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Gini_iOS_SDK/GiniSDK.h>

@interface AnalysisManager : NSObject

- (void)cancel;

- (void)analyzeDocumentWithImageData:(NSData *)data andCompletion:(void (^)(NSDictionary *, GINIDocument *, NSError *))completion;

@end
