//
//  AnalysisManager.m
//  GiniVisionExampleObjC
//
//  Created by Peter Pult on 11/08/16.
//  Copyright © 2016 Gini. All rights reserved.
//

#import "AnalysisManager.h"
#import "AppDelegate.h"
#import <Bolts/BFCancellationTokenSource.h>
#import <Gini/Gini-Swift.h>

NSString *const GINIAnalysisManagerDidReceiveResultNotification = @"GINIAnalysisManagerDidReceiveResultNotification";
NSString *const GINIAnalysisManagerDidReceiveErrorNotification  = @"GINIAnalysisManagerDidReceiveErrorNotification";
NSString *const GINIAnalysisManagerResultDictionaryUserInfoKey  = @"GINIAnalysisManagerResultDictionaryUserInfoKey";
NSString *const GINIAnalysisManagerErrorUserInfoKey             = @"GINIAnalysisManagerErrorUserInfoKey";
NSString *const GINIAnalysisManagerDocumentUserInfoKey          = @"GINIAnalysisManagerDocumentUserInfoKey";

@interface AnalysisManager () {
    BFCancellationTokenSource *_cancelationToken;
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
        _analyzing = NO;
    }
}

- (void)analyzeDocumentWithImageData:(NSData *)data
                       andCompletion:(void (^)(AnalysisResult *, GINIDocument *, NSError *))completion {
    
    // Cancel any running analysis process and set cancelation token.
    [self cancelAnalysis];
    _cancelationToken = [[BFCancellationTokenSource alloc] init];
    
    _analyzing = YES;
    
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
    if (_cancelationToken.cancellationRequested) {
        NSLog(@"Canceled analysis process");
        return;
    }
    
    // 1. Get session
    [[[[[sdk.sessionManager getSession] continueWithBlock:^id(BFTask *task) {
        if (self->_cancelationToken.cancellationRequested) {
            return [BFTask cancelledTask];
        }
        if (task.error) {
            return [sdk.sessionManager logIn];
        }
        return task.result;
        
    // 2. Create a document from the given image data
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (self->_cancelationToken.cancellationRequested) {
            return [BFTask cancelledTask];
        }
        return [manager createDocumentWithFilename:fileName fromData:data docType:@""];
        
    // 3. Get extractions from the document
    }] continueWithSuccessBlock:^id(BFTask *task) {
        if (self->_cancelationToken.cancellationRequested) {
            return [BFTask cancelledTask];
        }
        self->_document = (GINIDocument *)task.result;
        documentId = self->_document.documentId;
        NSLog(@"Created document with id: %@", documentId);
        
        return [manager getExtractionsForDocument:self->_document];
        
    // 4. Handle results
    }] continueWithBlock:^id(BFTask *task) {
        if (self->_cancelationToken.cancellationRequested || task.cancelled) {
            NSLog(@"Canceled analysis process");
            self->_analyzing = NO;
            return [BFTask cancelledTask];
        }
        
        NSLog(@"Finished analysis process");
        
        NSDictionary *userInfo;
        NSString *notificationName;
        
        if (task.error) {
            self->_error = task.error.copy;
            userInfo = @{GINIAnalysisManagerErrorUserInfoKey: self->_error};
            notificationName = GINIAnalysisManagerDidReceiveErrorNotification;
            if (completion) {
                completion(nil, nil, task.error);
            }
        } else {
            
            NSDictionary *dictionaryResult = ((NSDictionary *)task.result).copy;
                        
            NSMutableDictionary<NSString *, Extraction *> *extractions = [[NSMutableDictionary alloc] init];
            
            for (GINIExtraction *giniExtraction in dictionaryResult.allValues) {
                
                NSDictionary *giniBox = giniExtraction.box;
                
                Box *box = nil;
                
                if (giniBox != nil) {
                    box = [[Box alloc] initWithHeight:((NSNumber *)giniBox[@"height"]).doubleValue
                                                 left:((NSNumber *)giniBox[@"left"]).doubleValue
                                                 page:((NSNumber *)giniBox[@"page"]).integerValue
                                                  top:((NSNumber *)giniBox[@"top"]).doubleValue
                                                width:((NSNumber *)giniBox[@"width"]).doubleValue];
                }
                                                
                Extraction *extraction = [[Extraction alloc] initWithBox:box
                                                              candidates:nil
                                                                  entity:giniExtraction.entity
                                                                   value:giniExtraction.value
                                                                    name:giniExtraction.name];
                
                [extractions setObject:extraction forKey:giniExtraction.name];
            }
            
            AnalysisResult *analysisResult = [[AnalysisResult alloc] initWithExtractions:extractions
                                                                               lineItems:nil
                                                                                  images:[[NSArray alloc] init]];
            
            self->_result = analysisResult;
            userInfo = @{GINIAnalysisManagerResultDictionaryUserInfoKey: self->_result, GINIAnalysisManagerDocumentUserInfoKey: self->_document};
            notificationName = GINIAnalysisManagerDidReceiveResultNotification;
            if (completion) {
                completion(self->_result, self->_document, nil);
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
        });
        
        self->_analyzing = NO;
        return nil;
    }];
}

@end
