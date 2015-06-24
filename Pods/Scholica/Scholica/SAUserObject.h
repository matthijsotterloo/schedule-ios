//
//  SAUserObject.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Scholica.h"

@interface SAUserObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *source;
@property (nonatomic, assign) double internalBaseClassIdentifier;
@property (nonatomic, assign) int community;
@property (nonatomic, assign) BOOL superadmin;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSURL *picture;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) SARequestError *error;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
