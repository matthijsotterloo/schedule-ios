//
//  SARequestResult.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "Scholica.h"

@class SARequestResult, SARequestError;

@interface SARequestResult : NSObject

@property (nonatomic) NSDictionary* data;
@property (nonatomic) NSDictionary* meta;
@property (nonatomic) SARequestError* error;
@property (nonatomic) SARequestStatus status;

- (id) initWithData:(NSData*)data;

@end