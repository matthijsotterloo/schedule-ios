//
//  SANativeLoginController.h
//  Scholica
//
//  Created by Thomas Schoffelen on 01/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Scholica.h"

@interface SANativeLoginController : NSObject

+ (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure;

+ (BOOL) isRegisteredURLScheme:(NSString *)urlScheme;

+ (BOOL) validateURLSchemes;

+ (BOOL) applicationDelegateOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
