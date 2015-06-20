//
//  SAUtilities.m
//  Scholica
//
//  Created by Thomas Schoffelen on 01/05/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAUtilities.h"

@implementation SAUtilities

+ (NSDictionary *) parseQueryStringFromURL:(NSURL *)url {
    NSMutableDictionary *queryStrings = [[NSMutableDictionary alloc] init];
    for (NSString *qs in [url.query componentsSeparatedByString:@"&"]) {
        NSArray *components = [qs componentsSeparatedByString:@"="];
        
        NSString *key = [components objectAtIndex:0];
        NSString *value = [components objectAtIndex:1];
        
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        queryStrings[key] = value;
    }
    
    return queryStrings;
}

+ (NSData *) buildQueryString:(NSDictionary*)parameters {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in parameters) {
        id obj = [parameters objectForKey:key];
        NSString *valueString;
        
        if ([obj isKindOfClass:[NSString class]]){
            valueString = obj;
        }else if ([obj isKindOfClass:[NSNumber class]]){
            valueString = [(NSNumber *)obj stringValue];
        }else if ([obj isKindOfClass:[NSURL class]]){
            valueString = [(NSURL *)obj absoluteString];
        }else{
            valueString = [obj description];
        }
        
        valueString = [valueString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, valueString]];
    }
    NSString *postString = [array componentsJoinedByString:@"&"];
    
    return [postString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (void) redirectTo:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (NSString *)urlencode:(NSString *)string {
    return [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

+ (UIViewController *) getCurrentViewController {
    
    // Get rootviewcontroller
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    // Check if navigationcontroller, because then the current viewcontroller is known
    if([rootViewController isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController = (UINavigationController*)rootViewController;
        return navController.visibleViewController;
    }
    
    // Otherwise loop throught them until we hit a dead end
    UIViewController *currentController = rootViewController;
    while(currentController.presentedViewController != nil){
        currentController = currentController.presentedViewController;
    }
    
    return currentController;
}

@end
