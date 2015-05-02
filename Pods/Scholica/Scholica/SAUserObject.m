//
//  SAUserObject.m
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SAUserObject.h"

NSString *const kSAUserObjectSource = @"source";
NSString *const kSAUserObjectId = @"id";
NSString *const kSAUserObjectCommunity = @"community";
NSString *const kSAUserObjectSuperadmin = @"superadmin";
NSString *const kSAUserObjectEmail = @"email";
NSString *const kSAUserObjectUsername = @"username";
NSString *const kSAUserObjectPicture = @"picture";
NSString *const kSAUserObjectName = @"name";

@interface SAUserObject ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SAUserObject

@synthesize source = _source;
@synthesize internalBaseClassIdentifier = _internalBaseClassIdentifier;
@synthesize community = _community;
@synthesize superadmin = _superadmin;
@synthesize email = _email;
@synthesize username = _username;
@synthesize picture = _picture;
@synthesize name = _name;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.source = [self objectOrNilForKey:kSAUserObjectSource fromDictionary:dict];
        self.internalBaseClassIdentifier = [[self objectOrNilForKey:kSAUserObjectId fromDictionary:dict] doubleValue];
        self.community = [[self objectOrNilForKey:kSAUserObjectCommunity fromDictionary:dict] doubleValue];
        self.superadmin = [[self objectOrNilForKey:kSAUserObjectSuperadmin fromDictionary:dict] boolValue];
        self.email = [self objectOrNilForKey:kSAUserObjectEmail fromDictionary:dict];
        self.username = [[self objectOrNilForKey:kSAUserObjectUsername fromDictionary:dict] stringValue];
        self.picture = [NSURL URLWithString:[self objectOrNilForKey:kSAUserObjectPicture fromDictionary:dict]];
        self.name = [self objectOrNilForKey:kSAUserObjectName fromDictionary:dict];
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.source forKey:kSAUserObjectSource];
    [mutableDict setValue:[NSNumber numberWithDouble:self.internalBaseClassIdentifier] forKey:kSAUserObjectId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.community] forKey:kSAUserObjectCommunity];
    [mutableDict setValue:[NSNumber numberWithBool:self.superadmin] forKey:kSAUserObjectSuperadmin];
    [mutableDict setValue:self.email forKey:kSAUserObjectEmail];
    [mutableDict setValue:self.username forKey:kSAUserObjectUsername];
    [mutableDict setValue:self.picture forKey:kSAUserObjectPicture];
    [mutableDict setValue:self.name forKey:kSAUserObjectName];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.source = [aDecoder decodeObjectForKey:kSAUserObjectSource];
    self.internalBaseClassIdentifier = [aDecoder decodeDoubleForKey:kSAUserObjectId];
    self.community = [aDecoder decodeDoubleForKey:kSAUserObjectCommunity];
    self.superadmin = [aDecoder decodeBoolForKey:kSAUserObjectSuperadmin];
    self.email = [aDecoder decodeObjectForKey:kSAUserObjectEmail];
    self.username = [aDecoder decodeObjectForKey:kSAUserObjectUsername];
    self.picture = [aDecoder decodeObjectForKey:kSAUserObjectPicture];
    self.name = [aDecoder decodeObjectForKey:kSAUserObjectName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_source forKey:kSAUserObjectSource];
    [aCoder encodeDouble:_internalBaseClassIdentifier forKey:kSAUserObjectId];
    [aCoder encodeDouble:_community forKey:kSAUserObjectCommunity];
    [aCoder encodeBool:_superadmin forKey:kSAUserObjectSuperadmin];
    [aCoder encodeObject:_email forKey:kSAUserObjectEmail];
    [aCoder encodeObject:_username forKey:kSAUserObjectUsername];
    [aCoder encodeObject:_picture forKey:kSAUserObjectPicture];
    [aCoder encodeObject:_name forKey:kSAUserObjectName];
}

- (id)copyWithZone:(NSZone *)zone
{
    SAUserObject *copy = [[SAUserObject alloc] init];
    
    if (copy) {
        copy.source = [self.source copyWithZone:zone];
        copy.internalBaseClassIdentifier = self.internalBaseClassIdentifier;
        copy.community = self.community;
        copy.superadmin = self.superadmin;
        copy.email = [self.email copyWithZone:zone];
        copy.username = self.username;
        copy.picture = [self.picture copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
    }
    
    return copy;
}


@end
