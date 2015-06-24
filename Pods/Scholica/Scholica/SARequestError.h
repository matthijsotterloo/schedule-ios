//
//  SARequestError.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "Scholica.h"

@interface SARequestError : NSObject

@property (nonatomic) NSDictionary* data;
@property (nonatomic) int code;
@property (nonatomic) NSString* errorDescription;
@property (nonatomic) NSString* documentationURL;

- (id) initWithData:(NSDictionary*)data;

@end