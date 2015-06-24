//
//  SAUtilities.h
//  Scholica
//
//  Created by Thomas Schoffelen on 01/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAUtilities : NSObject

+ (NSDictionary *) parseQueryStringFromURL:(NSURL *)url;

+ (NSData *) buildQueryString:(NSDictionary*)parameters;

+ (void) redirectTo:(NSString *)url;

+ (NSString *)urlencode:(NSString *)string;

+ (UIViewController *) getCurrentViewController;

@end
