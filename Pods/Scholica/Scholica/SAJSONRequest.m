//
//  SAJSONRequest.m
//  Scholica
//
//  Created by Thomas Schoffelen on 02/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SAJSONRequest.h"

@implementation SAJSONRequest

+ (void) request:(NSString *)url parameters:(NSDictionary *)params callback:(SARequestCallback)callback {
    
    NSData *postData = [SAUtilities buildQueryString:params];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:[Scholica instance].requestTimeout];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[[NSNumber numberWithUnsignedInteger:[postData length]] stringValue] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        if (callback) {
            NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
            SARequestResult* result = [SARequestResult alloc];
            if (!connectionError && (responseCode == 200 || responseCode >= 400 || responseCode == 500)) {
                result = [result initWithData:data];

                if (!result.data) {
                    result.status = SARequestStatusError;
                    result.error = [[SARequestError alloc] initWithData:@{
                        @"code": @"-1",
                        @"description": @"Response is unreadable",
                        @"documentation": @""
                    }];
                }
            }else{
                result = [result init];
                result.status = SARequestStatusError;
                result.error = [[SARequestError alloc] initWithData:@{
                    @"code": [NSString stringWithFormat:@"%ld", (long)responseCode],
                    @"description": connectionError?connectionError.description:@"Unknown error",
                    @"documentation": @""
                }];
            }
        
            callback(result);
        }
    }];
}

@end
