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
    [self cancelAnalysis];
    _cancelationToken = token;
    
    /*********************************************
     * UPLOAD DOCUMENT WITH THE GINI SDK FOR IOS *
     *********************************************/
        
    // Get current Gini SDK instance to upload image and process exctraction
    GiniSDK *sdk = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).giniSDK;
    
    // Create a document task manager to handle document tasks on the Gini API
    GINIDocumentTaskManager *manager = sdk.documentTaskManager;
    
    // Create a file name for the document
    NSString *fileName = @"your_filename";
    
    __block NSString *documentId;
    
    if (token.cancelled) {
        return;
    }
    [[[[[sdk.sessionManager getSession] continueWithBlock:^id(BFTask *task) {
        if (token.cancelled) {
            return [BFTask cancelledTask];
        }
        if (task.error) {
            return [sdk.sessionManager logIn];
        }
        return task.result;
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (token.cancelled) {
            return [BFTask cancelledTask];
        }
        return [manager createDocumentWithFilename:fileName fromData:data docType:@""];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (token.cancelled) {
            return [BFTask cancelledTask];
        }
        _document = (GINIDocument *)task.result;
        documentId = _document.documentId;
        NSLog(@"documentId: %@", documentId);
        return _document.extractions;
    }] continueWithBlock:^id(BFTask *task) {
        if (token.cancelled || task.cancelled) {
            return [BFTask cancelledTask];
        }
        
        if (task.error) {
            _error = task.error.copy;
            NSDictionary *userInfo = @{GINIAnalysisManagerErrorUserInfoKey: _error};
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:GINIAnalysisManagerDidReceiveErrorNotification
                                                                    object:self
                                                                  userInfo:userInfo];
            });
            if (completion) {
                completion(nil, nil, task.error);
            }
            return nil;
        }
        
        NSLog(@"received extractions");
        _result = ((NSDictionary *)task.result).copy;
        NSDictionary *userInfo = @{GINIAnalysisManagerResultDictionaryUserInfoKey: _result, GINIAnalysisManagerDocumentUserInfoKey: _document};
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:GINIAnalysisManagerDidReceiveResultNotification
                                                                object:self
                                                              userInfo:userInfo];
        });
        if (completion) {
            completion(_result, _document, nil);
        }
        return nil;
    }];
}

@end
