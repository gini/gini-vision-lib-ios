//
//  CredentialsManager.m
//  Example ObjC
//
//  Created by Enrique del Pozo Gómez on 5/9/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

#import "CredentialsManager.h"

NSString *const kClientId = @"client_id";
NSString *const kClientPassword = @"client_password";
NSString *const kClientDomain = @"client_domain";

@implementation CredentialsManager

- (NSDictionary<NSString*, NSString*> *)getCredentials {
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                       pathForResource:@"Credentials"
                                                       ofType:@"plist"]];
}

@end
