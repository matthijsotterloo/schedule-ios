//
//  Scholica.m
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "Scholica.h"

@implementation Scholica

static SAUserObject *userProfile;

- (id) init {
    self.endPoint = @"https://api.scholica.com/2.0";
    self.authEndPoint = @"https://secure.scholica.com";
    self.autoSaveAccessToken = YES;
    self.requestTimeout = 30;
    
    return [super init];
}

- (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure viewController:(UIViewController *)viewController {
    BOOL native = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"scholicasignin://key/authenticate"]];
    
    if(native && [SANativeLoginController validateURLSchemes]){
        [SANativeLoginController signIn:success failure:failure];
    }else{
        [SAWebLoginController signIn:success failure:failure viewController:viewController];
    }
}

- (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure {
    [self signIn:success failure:failure viewController:[SAUtilities getCurrentViewController]];
}

- (BOOL) applicationDelegateOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [SANativeLoginController applicationDelegateOpenURL:url sourceApplication:sourceApplication];
}

- (BOOL) isAccessTokenSet {
    return self.accessToken && ![self.accessToken isEqualToString:@""];
}

- (BOOL) currentSession {
    if(![self isAccessTokenSet] && self.autoSaveAccessToken){
        [SASession retrieveAccessToken];
    }
    
    if([self isAccessTokenSet]){
        return YES;
    }
    
    return NO;
}

- (void) signOut {
    userProfile = nil;
    if(self.autoSaveAccessToken){
        [SASession destroyAccessToken];
    }
    [self setAccessToken:nil];
}

- (void) getRequestToken:(SARequestCallback)callback {
    if(![self isAccessTokenSet] && self.autoSaveAccessToken){
        [SASession retrieveAccessToken];
    }
    
    if(![self isAccessTokenSet]){
        @throw [NSException exceptionWithName:@"ScholicaException" reason:@"accessToken not set" userInfo:nil];
    }
    if(!self.consumerSecret){
        @throw [NSException exceptionWithName:@"ScholicaException" reason:@"consumerSecret not set" userInfo:nil];
    }
    
    NSDictionary *params = @{
                             @"access_token"   : self.accessToken,
                             @"consumer_secret": self.consumerSecret
                            };
    
    NSString *fullURL = [NSString stringWithFormat:@"%@/token", self.authEndPoint];
    
    [SAJSONRequest request:fullURL parameters:params callback:^(SARequestResult *result) {
        if(result.status != SARequestStatusError){
            if ([[result.data objectForKey:@"status"] isEqualToString:@"ok"]) {
                if([result.data objectForKey:@"request_token"]){
                    self.requestToken = [result.data objectForKey:@"request_token"];
                }else{
                    result.status = SARequestStatusError;
                    result.error = [[SARequestError alloc] initWithData:@{
                        @"code": @"-1",
                        @"description": @"requestToken is missing from result",
                        @"documentation": @""
                    }];
                }
            }else{
                result.status = SARequestStatusError;
                result.error = [[SARequestError alloc] initWithData:@{
                   @"code": @"-1",
                   @"description": @"status is not equal to ok",
                   @"documentation": @""
                }];
            }
        }
        callback(result);
    }];
}

- (void) request:(NSString*)method withFields:(NSDictionary*)fields callback:(SARequestCallback)callback {
    if(!self.requestToken){
        [self getRequestToken:^(SARequestResult* result){
            if(result.status == SARequestStatusOK){
                [self request:method withFields:fields callback:callback];
            }else if(callback){
                callback(result);
            }
        }];
        return;
    }
    
    NSMutableDictionary* postFields = [fields mutableCopy];
    [postFields setValue:self.requestToken forKey:@"token"];
    
    if([method rangeOfString:@"/"].location != 0){
        method = [NSString stringWithFormat:@"/%@", method];
    }
    NSString *fullURL = [NSString stringWithFormat:@"%@%@", self.endPoint, method];
    
    [SAJSONRequest request:fullURL parameters:postFields callback:callback];
}

- (void) request:(NSString*)method callback:(SARequestCallback)callback {
    return [self request:method withFields:@{} callback:callback];
}

- (void) profile:(SAProfileCallback)callback {
    NSAssert(callback, @"Callback may not be nil");
    
    if(userProfile){
        callback(userProfile);
    }else{
        [self request:@"me" callback:^(SARequestResult *result) {
            if(result.status == SARequestStatusOK){
                SAUserObject *user = [[SAUserObject alloc] initWithDictionary:result.data];
                callback(user);
            }else{
                SAUserObject *user = nil;
                user.error = result.error;
                callback(user);
            }
        }];
    }
}

@end
