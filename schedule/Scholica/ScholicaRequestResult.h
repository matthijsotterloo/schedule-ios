//
//  ScholicaRequestResult.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "Scholica.h"

@class ScholicaRequestResult, ScholicaRequestError;

@interface ScholicaRequestResult : NSObject

@property (nonatomic) NSDictionary* data;
@property (nonatomic) NSDictionary* meta;
@property (nonatomic) ScholicaRequestError* error;
@property (nonatomic) ScholicaRequestStatus status;

- (id) initWithData:(NSData*)data;

@end