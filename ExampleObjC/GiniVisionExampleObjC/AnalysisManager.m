//
//  AnalysisManager.m
//  GiniVisionExampleObjC
//
//  Created by Gini on 11/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "AnalysisManager.h"
#import "AppDelegate.h"

@interface AnalysisManager ()

@property (nonatomic, assign) BOOL cancelled;

@end

@implementation AnalysisManager

- (void)cancel {
    _cancelled = YES;
}

- (void)analyzeDocumentWithImageData:(NSData *)data andCompletion:(void (^)(NSDictionary *, GINIDocument *, NSError *))completion {
    /*********************************************
     * UPLOAD DOCUMENT WITH THE GINI SDK FOR IOS *
     *********************************************/
        
    // Get current Gini SDK instance to upload image and process exctraction
    GiniSDK *sdk = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;
    
    // Create a document task manager to handle document tasks on the Gini API
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;
    
    // Create a file name for the document
    NSString *fileName = @"your_filename";
    
    __block GINIDocument *giniDocument;
    __block NSString *documentId;
    
    if (_cancelled) {
        return;
    }
    [[[[[sdk.sessionManager getSession] continueWithBlock:^id(BFTask *task) {
        if (_cancelled) {
            return [BFTask cancelledTask];
        }
        if (task.error) {
            return [sdk.sessionManager logIn];
        }
        return task.result;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (_cancelled) {
            return [BFTask cancelledTask];
        }
        return [manager createDocumentWithFilename:fileName fromData:data docType:@""];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (_cancelled) {
            return [BFTask cancelledTask];
        }
        giniDocument = (GINIDocument *)task.result;
        documentId = giniDocument.documentId;
        NSLog(@"documentId: %@", documentId);
        return giniDocument.extractions;
    }] continueWithBlock:^id(BFTask *task) {
        if (_cancelled || task.cancelled) {
            return [BFTask cancelledTask];
        }
        if (task.error) {
            completion(nil, nil, task.error);
            return nil;
        }
        completion((NSDictionary *)task.result, giniDocument, nil);
        return nil;
    }];
}

@end
