//
//  ScholicaRequestError.m
//  Created by Tom Schoffelen on 21-04-14.
//

#import "ScholicaRequestError.h"

@implementation ScholicaRequestError

- (id) initWithData:(NSDictionary*)data {
    
    self.data = data;
    
    self.code = [[data objectForKey:@"code"] intValue];
    self.errorDescription = [data objectForKey:@"description"];
    self.documentationURL = [data objectForKey:@"documentation"];
    
    return [super init];
}

@end
