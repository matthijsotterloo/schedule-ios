//
//  SASession.m
//  Scholica
//
//  Created by Thomas Schoffelen on 02/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SASession.h"

@implementation SASession

+ (void) retrieveAccessToken {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScholicaAccessToken"];
    if(accessToken){
        [[Scholica instance] setAccessToken:accessToken];
    }
}

+ (void) saveAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"ScholicaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) destroyAccessToken {
    [[Scholica instance] request:[NSString stringWithFormat:@"consumers/%@/bundle/%@/deactivate", [Scholica instance].consumerKey, [[NSBundle mainBundle] bundleIdentifier]] callback:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScholicaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
