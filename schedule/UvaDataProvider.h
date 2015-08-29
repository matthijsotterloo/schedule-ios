//
//  UvaDataProvider.h
//  schedule
//
//  Created by Thomas Schoffelen on 29/08/2015.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
#import "Scholica.h"

@interface UvaDataProvider : SASingleton

@property (atomic) NSString* token;

- (void) profile:(SAProfileCallback)callback;

- (void)getCalendarWithTimestamp:(NSNumber*)time callback:(SARequestCallback)callback;

@end
