//
//  SANativeLoginController.m
//  Scholica
//
//  Created by Thomas Schoffelen on 01/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SANativeLoginController.h"

@implementation SANativeLoginController

static SALoginCallback loginSuccessCallback;
static SALoginCallback loginFailureCallback;

+ (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure {
    loginSuccessCallback = success;
    loginFailureCallback = failure;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"scholicasignin://%@/authenticate", [Scholica instance].consumerKey]];
    dispatch_async(dispatch_get_main_queue(), ^{
        // Dispatch openURL calls to prevent hangs if we're inside the current app delegate's openURL flow already
        [[UIApplication sharedApplication] openURL:url];
    });
}

+ (BOOL) validateURLSchemes {
    if (![SANativeLoginController isRegisteredURLScheme:[Scholica instance].consumerKey]) {
        NSLog(@"Warning: Your consumer key is not registered as a URL scheme. Please add it in your Info.plist to allow signing in through the native Scholica app.");
        return NO;
    }
    return YES;
}

+ (BOOL) isRegisteredURLScheme:(NSString *)urlScheme {
    static dispatch_once_t fetchBundleOnce;
    static NSArray *urlTypes = nil;
    
    dispatch_once(&fetchBundleOnce, ^{
        urlTypes = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleURLTypes"];
    });
    for (NSDictionary *urlType in urlTypes) {
        NSArray *urlSchemes = [urlType valueForKey:@"CFBundleURLSchemes"];
        if ([urlSchemes containsObject:urlScheme]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL) applicationDelegateOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    if([url.scheme isEqualToString:[Scholica instance].consumerKey]){
        if([sourceApplication isEqualToString:@"com.scholica.iphone"] || [sourceApplication isEqualToString:@"com.scholica.loginDemo"]){
            if([url.host isEqualToString:@"auth-success"]){
                NSString *accessToken = [[SAUtilities parseQueryStringFromURL:url] objectForKey:@"access_token"];
                [[Scholica instance] setAccessToken:accessToken];
                if([[Scholica instance] autoSaveAccessToken]){
                    [SASession saveAccessToken:accessToken];
                }
                loginSuccessCallback(SALoginStatusOK);
                return YES;
            }else if([url.host isEqualToString:@"auth-failure"]){
                SALoginStatus status = (SALoginStatus)[[SAUtilities parseQueryStringFromURL:url] objectForKey:@"access_token"];
                loginFailureCallback(status);
                return YES;
            }
        }
    }
    return NO;
}

@end
