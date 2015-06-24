//
//  SARequestResult.m
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "Scholica.h"

@implementation SARequestResult

- (id) initWithData:(NSData*)data {
    
    NSError* errorObject;
    @try {
        self.data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errorObject];
        if([self.data objectForKey:@"meta"]){
            self.meta = [self.data objectForKey:@"meta"];
        }
        if([self.data objectForKey:@"error"]){
            self.status = SARequestStatusError;
            self.error = [[SARequestError alloc] initWithData:[self.data objectForKey:@"error"]];
        }else{
            self.status = SARequestStatusOK;
            if([self.data objectForKey:@"result"]){
                self.data = [self.data objectForKey:@"result"];
            }
        }
    }
    @catch(NSException* exception){
        self.data = @{};
        self.status = SARequestStatusError;
        self.error = [[SARequestError alloc] initWithData:@{
                                                                  @"code": @"999",
                                                                  @"description": @"Response is no valid JSON",
                                                                  @"documentation": @""
                                                                  }];
    }
    
    return [super init];
}

@end
