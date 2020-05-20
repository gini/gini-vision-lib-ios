//
//  CredentialsManager.h
//  Example ObjC
//
//  Created by Enrique del Pozo Gómez on 5/9/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kClientId;
extern NSString *const kClientPassword;
extern NSString *const kClientDomain;

@interface CredentialsManager: NSObject

- (NSDictionary<NSString*, NSString*> *)getCredentials;

@end
