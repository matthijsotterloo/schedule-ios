//
//  SARequestError.m
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SARequestError.h"

@implementation SARequestError

- (id) initWithData:(NSDictionary*)data {
    
    self.data = data;
    
    self.code = [[data objectForKey:@"code"] intValue];
    self.errorDescription = [data objectForKey:@"description"];
    self.documentationURL = [data objectForKey:@"documentation"];
    
    return [super init];
}

@end
