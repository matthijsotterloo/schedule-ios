//
//  Scholica.m
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "Scholica.h"

@implementation Scholica

- (id) init {
    self.endPoint = @"https://api.scholica.com/2.0";
    self.authEndPoint = @"https://secure.scholica.com";
    self.requestTimeout = 30;
    
    return [super init];
}

- (id) initWithConsumerKey:(NSString*)consumerKey secret:(NSString*)consumerSecret {
    
    self.consumerKey = consumerKey;
    self.consumerSecret = consumerSecret;
    
    return [self init];
}

- (void) loginInViewController:(UIViewController*)viewController success:(ScholicaLoginCallback)success failure:(ScholicaLoginCallback)failure {
    
    // Create a view controller (ScholicaLoginController)
    ScholicaLoginController *loginController = [[ScholicaLoginController alloc] init];
    
    // Transfer settings
    loginController.endPoint = self.authEndPoint;
    loginController.consumerKey = self.consumerKey;
    loginController.customLoginProcess = self.customLoginProcess;
    
    // Set redirect URI
    loginController.redirectUri = @"webview://x-callback-url/auth";
    
    // Set callbacks
    __block ScholicaLoginController* loginControllerShim = loginController;
    loginController.callback = ^{
        if(loginControllerShim.status == ScholicaLoginStatusOK){
            self.accessToken = [NSString stringWithString:loginControllerShim.accessToken];
            success(loginControllerShim.status);
        }else{
            failure(loginControllerShim.status);
        }
        
        if (!self.customDismissLoginController){
            [viewController dismissViewControllerAnimated:YES completion:nil];
            loginControllerShim.shouldHide = YES;
        }
    };
    
    // Present view controller
    loginController.shouldHide = NO;
    [viewController presentViewController:loginController animated:YES completion:nil];
}

- (void) getRequestToken:(ScholicaRequestCallback)callback {
    if(!self.accessToken){
        @throw [NSException
                exceptionWithName:@"ScholicaException"
                reason:@"accessToken not set"
                userInfo:nil];
    }
    if(!self.consumerSecret){
        @throw [NSException
                exceptionWithName:@"ScholicaException"
                reason:@"consumerSecret not set"
                userInfo:nil];
    }
    
    NSDictionary *params = @{
                             @"access_token"   : self.accessToken,
                             @"consumer_secret": self.consumerSecret
                            };
    
    NSData *postData = [self buildQueryString:params];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/token", self.authEndPoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:self.requestTimeout];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        ScholicaRequestResult* result = [ScholicaRequestResult alloc];
        if (!connectionError && responseCode == 200) {
            result = [result initWithData:data];
            
            if(result.status != ScholicaRequestStatusError){
                if ([[result.data objectForKey:@"status"] isEqualToString:@"ok"]) {
                    if([result.data objectForKey:@"request_token"]){
                        self.requestToken = [result.data objectForKey:@"request_token"];
                    }else{
                        result.status = ScholicaRequestStatusError;
                        result.error = [[ScholicaRequestError alloc] initWithData:@{
                                                                                    @"code": @"-1",
                                                                                    @"description": @"requestToken is missing from result",
                                                                                    @"documentation": @""
                                                                                    }];
                    }
                }else{
                    result.status = ScholicaRequestStatusError;
                    result.error = [[ScholicaRequestError alloc] initWithData:@{
                                                                                @"code": @"-1",
                                                                                @"description": @"status is not qual to ok",
                                                                                @"documentation": @""
                                                                                }];
                }
            }
        }else{
            result = [result init];
            result.status = ScholicaRequestStatusError;
            result.error = [[ScholicaRequestError alloc] initWithData:@{
                                                                        @"code": [NSString stringWithFormat:@"%ld", (long)responseCode],
                                                                        @"description": connectionError?connectionError.description:@"Unknown error",
                                                                        @"documentation": @""
                                                                        }];
        }
        callback(result);
    }];
}

- (void) request:(NSString*)method withFields:(NSDictionary*)fields callback:(ScholicaRequestCallback)callback {
    if(!self.requestToken){
        [self getRequestToken:^(ScholicaRequestResult* result){
            if(result.status == ScholicaRequestStatusOK){
                [self request:method withFields:fields callback:callback];
            }else{
                callback(result);
            }
        }];
        return;
    }
    
    NSMutableDictionary* postFields = [fields mutableCopy];
    [postFields setValue:self.requestToken forKey:@"token"];
    
    NSData *postData = [self buildQueryString:postFields];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    if([method rangeOfString:@"/"].location != 0){ method = [NSString stringWithFormat:@"/%@", method]; }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.endPoint, method]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:self.requestTimeout];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        ScholicaRequestResult* result = [ScholicaRequestResult alloc];
        if (!connectionError && (responseCode == 200 || responseCode >= 400 || responseCode == 500)) {
            result = [result initWithData:data];
            
            if (!result.data) {
                result.status = ScholicaRequestStatusError;
                result.error = [[ScholicaRequestError alloc] initWithData:@{
                                                                            @"code": @"-1",
                                                                            @"description": @"Response is unreadable",
                                                                            @"documentation": @""
                                                                            }];
            }
        }else{
            result = [result init];
            result.status = ScholicaRequestStatusError;
            result.error = [[ScholicaRequestError alloc] initWithData:@{
                                                                        @"code": [NSString stringWithFormat:@"%ld", (long)responseCode],
                                                                        @"description": connectionError?connectionError.description:@"Unknown error",
                                                                        @"documentation": @""
                                                                        }];
        }
        callback(result);
    }];
}

- (void) request:(NSString*)method callback:(ScholicaRequestCallback)callback {
    return [self request:method withFields:@{} callback:callback];
}

- (NSData *) buildQueryString:(NSDictionary*)parameters {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in parameters) {
        id obj = [parameters objectForKey:key];
        NSString *valueString;
        
        if ([obj isKindOfClass:[NSString class]]){
            valueString = obj;
        }else if ([obj isKindOfClass:[NSNumber class]]){
            valueString = [(NSNumber *)obj stringValue];
        }else if ([obj isKindOfClass:[NSURL class]]){
            valueString = [(NSURL *)obj absoluteString];
        }else{
            valueString = [obj description];
        }
        
        valueString = [valueString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, valueString]];
    }
    NSString *postString = [array componentsJoinedByString:@"&"];
    
    return [postString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
