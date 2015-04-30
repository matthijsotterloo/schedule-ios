//
//  ScholicaRequestResult.h
//  Created by Tom Schoffelen on 21-04-14.
//

#import <Foundation/Foundation.h>
#import "Scholica.h"

@class ScholicaRequestResult, ScholicaRequestError;

@interface ScholicaRequestResult : NSObject

@property (nonatomic) NSDictionary* data;
@property (nonatomic) NSDictionary* meta;
@property (nonatomic) ScholicaRequestError* error;
@property (nonatomic) ScholicaRequestStatus status;
//@property (nonatomic) NSString* requestToken;

- (id) initWithData:(NSData*)data;

@end