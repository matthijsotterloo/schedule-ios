//
//  SAJSONRequest.h
//  Scholica
//
//  Created by Thomas Schoffelen on 02/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Scholica.h"

@interface SAJSONRequest : NSObject

+ (void) request:(NSString *)url parameters:(NSDictionary *)params callback:(SARequestCallback)callback;

@end
