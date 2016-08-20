//
//  AnalysisManager.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 11/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "AnalysisManager.h"
#import "AppDelegate.h"

NSString *const GINIAnalysisManagerDidReceiveResultNotification = @"GINIAnalysisManagerDidReceiveResultNotification";
NSString *const GINIAnalysisManagerDidReceiveErrorNotification  = @"GINIAnalysisManagerDidReceiveErrorNotification";
NSString *const GINIAnalysisManagerResultDictionaryUserInfoKey  = @"GINIAnalysisManagerResultDictionaryUserInfoKey";
NSString *const GINIAnalysisManagerErrorUserInfoKey             = @"GINIAnalysisManagerErrorUserInfoKey";
NSString *const GINIAnalysisManagerDocumentUserInfoKey          = @"GINIAnalysisManagerDocumentUserInfoKey";

@interface AnalysisManager () {
    CancelationToken *_cancelationToken;
}

@end

@implementation AnalysisManager

+ (instancetype)sharedManager {
    static AnalysisManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [self new];
    });
    return sharedMyManager;
}

- (void)cancelAnalysis {
    if (_cancelationToken) {
        [_cancelationToken cancel];
        _result = nil;
        _document = nil;
        _error = nil;
    }
}

- (void)analyzeDocumentWithImageData:(NSData *)data
                    cancelationToken:(CancelationToken *)token
                       andCompletion:(void (^)(NSDictionary *, GINIDocument *, NSError *))completion {
    
    // Cancel any running analysis process and set cancelation token.
    [self cancelAnalysis];
    _cancelationToken = token;
    
    /**********************************************
     * ANALYZE DOCUMENT WITH THE GINI SDK FOR IOS *
     **********************************************/
    
    NSLog(@"Started analysis process");
    
    // Get current Gini SDK instance to upload image and process exctraction.
    GiniSDK *sdk = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;
    
    // Create a document task manager to handle document tasks on the Gini API.
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;
    
    // Create a file name for the document.
    NSString *fileName = @"your_filename";
    
    __block NSString *documentId;
    
    // Return early when process was canceled.
    if (token.cancelled) {
        NSLog(@"Canceled analysis process");
        return;
    }
    
    // 1. Get session
    [[[[[sdk.sessionManager getSession] continueWithBlock:^id(BFTask *task) {
        if (token.cancelled) {
            return [BFTask cancelledTask];
        }
        if (task.error) {
            return [sdk.sessionManager logIn];
        }
        return task.result;
        
    // 2. Create a document from the given image data
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (token.cancelled) {
            return [BFTask cancelledTask];
        }
        return [manager createDocumentWithFilename:fileName fromData:data docType:@""];
        
    // 3. Get extractions from the document
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (token.cancelled) {
            return [BFTask cancelledTask];
        }
        _document = (GINIDocument *)task.result;
        documentId = _document.documentId;
        NSLog(@"Created document with id: %@", documentId);
        
        return _document.extractions;
        
    // 4. Handle results
    }] continueWithBlock:^id(BFTask *task) {
        if (token.cancelled || task.cancelled) {
            NSLog(@"Canceled analysis process");
            return [BFTask cancelledTask];
        }
        
        NSLog(@"Finished analysis process");
        
        NSDictionary *userInfo;
        NSString *notificationName;
        
        if (task.error) {
            _error = task.error.copy;
            userInfo = @{GINIAnalysisManagerErrorUserInfoKey: _error};
            notificationName = GINIAnalysisManagerDidReceiveErrorNotification;
            if (completion) {
                completion(nil, nil, task.error);
            }
        } else {
            _result = ((NSDictionary *)task.result).copy;
            userInfo = @{GINIAnalysisManagerResultDictionaryUserInfoKey: _result, GINIAnalysisManagerDocumentUserInfoKey: _document};
            notificationName = GINIAnalysisManagerDidReceiveResultNotification;
            if (completion) {
                completion(_result, _document, nil);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
        });
        
        return nil;
    }];
}

@end
