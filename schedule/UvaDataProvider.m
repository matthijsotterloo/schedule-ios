//
//  UvaDataProvider.m
//  schedule
//
//  Created by Thomas Schoffelen on 29/08/2015.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "UvaDataProvider.h"

@implementation UvaDataProvider

- (void) JSONRequest:(NSString *)method callback:(SARequestCallback)callback {
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.inqdoconnect.nl/rest/uva/v1/%@", method]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:[Scholica instance].requestTimeout];
    
    NSLog(@"Using Authorization: Bearer %@", self.token);
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.token] forHTTPHeaderField:@"Authorization"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                               });
                               
                               if (callback) {
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   SARequestResult* result = [SARequestResult alloc];
                                   if (!connectionError && (responseCode == 200 || responseCode >= 400)) {
                                       result = [result initWithData:data];
                                       if (!result.data) {
                                           result.status = SARequestStatusError;
                                           result.error = [[SARequestError alloc] initWithData:@{
                                                                                                 @"code": (responseCode == 200 ? @"-1" : [NSNumber numberWithInteger:responseCode]),
                                                                                                 @"description": @"Response is unreadable",
                                                                                                 @"documentation": @""
                                                                                                 }];
                                       }
                                       
                                       if([result.data objectForKey:@"provider_error"]){
                                           UIAlertView* alert =[[UIAlertView alloc] initWithTitle:@"Login error" message:[result.data objectForKey:@"provider_error"] delegate:[SSDataProvider instance] cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                           [alert show];
                                           return;
                                       }
                                       
                                   }else{
                                       result = [result init];
                                       result.status = SARequestStatusError;
                                       result.error = [[SARequestError alloc] initWithData:@{
                                                                                             @"code": [NSString stringWithFormat:@"%ld", (long)responseCode],
                                                                                             @"description": connectionError?connectionError.description:@"Unknown error",
                                                                                             @"documentation": @""
                                                                                             }];
                                   }
                                   
                                   callback(result);
                               }
                           }];
}

- (NSDate *)getFirstDayOfTheWeekFromDate:(NSDate *)givenDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comps = [calendar components:NSYearForWeekOfYearCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:givenDate];
    
    [comps setWeekday:2]; // 2: monday
    return [calendar dateFromComponents:comps];
}

- (void) profile:(SAProfileCallback)callback {
    [self JSONRequest:@"profiles" callback:^(SARequestResult *result) {
        if(result.status == SARequestStatusOK){
            [[SSDataProvider instance] saveSession];
            
            NSArray* users = [result.data objectForKey:@"data"];
            NSDictionary* firstUser = [users objectAtIndex:0];
            
            SAUserObject *user = [[SAUserObject alloc] init];
            user.name = [firstUser objectForKey:@"username"];
            user.username = [firstUser objectForKey:@"userId"];
            user.community = 99999; // Is required for the sync to function
            
            /* Also available: 
                 firstUser.university = "Universiteit van Amsterdam";
                 firstUser.universityCode = "UvA";
            */
            
            callback(user);
        }else{
            SAUserObject *user = [[SAUserObject alloc] init];
            NSLog(@"Eror: %@", result.error.errorDescription);
            user.error = result.error;
            callback(user);
        }
    }];
}

- (void)getCalendarWithTimestamp:(NSNumber*)time callback:(SARequestCallback)callback {
    if(![time boolValue]){
        time = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    }
    
    NSDate* requestedDate = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
    NSDate* weekStart = [self getFirstDayOfTheWeekFromDate:requestedDate];
    NSNumber* weekStartUnix = [NSNumber numberWithDouble:[weekStart timeIntervalSince1970]];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    [self JSONRequest:@"schedule" callback:^(SARequestResult *result) {
        NSLog(@"res: %@", result);
        if(result.status == SARequestStatusOK){
            NSMutableDictionary* days = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* dayIndexes = [[NSMutableDictionary alloc] init];
            NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            
            // Initial days array
            for(int z = 0; z < 5; z++){
                // Get day date
                NSDateComponents* comps = [calendar components:NSYearForWeekOfYearCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:weekStart];
                [comps setWeekday:(2+z)];
                NSDate *dayDate = [calendar dateFromComponents:comps];
                
                // Get day index
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"g"];
                [dayIndexes setObject:[NSString stringWithFormat:@"%d", z] forKey:[dateFormatter stringFromDate:dayDate]];
                NSLog(@"da: %@", [dateFormatter stringFromDate:dayDate]);
                NSLog(@"date = %@", dayDate);
                
                // Get day title
                [dateFormatter setDateFormat:@"EEEE"];
                NSMutableDictionary* dayDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                 @"day_title": [dateFormatter stringFromDate:dayDate],
                                                 @"day_ofweek": [NSNumber numberWithDouble:(z+1)],
                                                 @"items": [NSMutableArray new]
                                                 }];
                [days setObject:dayDict forKey:[NSString stringWithFormat:@"%d", z]];
            }
            
            //NSLog(@"days count: %lu", (unsigned long)[days count]);
            
            // Loop through appointments
            NSArray* scheduleItems = [result.data objectForKey:@"data"];
            for (int i = 0; i < [scheduleItems count]; i++) {
                // Get appointment
                NSDictionary* appointment = [scheduleItems objectAtIndex:i];
                
                // Convert to NSDate
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                [formatter setLocale:posix];
                NSDate *date = [formatter dateFromString:[appointment objectForKey:@"startDate"]];
                NSLog(@"date = %@", date);
                
                // Get julian day
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"g"];
                NSString* dayKey = [dateFormatter stringFromDate:date];
                NSLog(@"dk: %@", dayKey);
                if([dayIndexes objectForKey:dayKey]){
                    // Day is part of the week, so let's parse it
                    NSString* dayIndex = [dayIndexes objectForKey:dayKey];
                    [dateFormatter setDateFormat:@"HH:mm"];
                    NSString* start_str = [dateFormatter stringFromDate:date];
                    NSNumber* start = [NSNumber numberWithDouble:[date timeIntervalSince1970]];
                    NSDictionary* location = [[appointment objectForKey:@"locations"] objectAtIndex:0];
                    NSString* subtitle = [NSString stringWithFormat:@"%@ - %@", [location objectForKey:@"name"], [appointment objectForKey:@"notes"]];
                    NSLog(@"Dayitems: %@", [[days objectForKey:dayIndex] objectForKey:@"items"]);
                    [[[days objectForKey:dayIndex] objectForKey:@"items"] addObject:@{
                                                                                      @"title": [appointment objectForKey:@"activity"],
                                                                                      @"subtitle": subtitle,
                                                                                      @"start": start,
                                                                                      @"start_str": start_str
                                                                                       }];
                }
            }
            
            // Remove empty days
            for(int z = 0; z < 5; z++){
                if([[[days objectForKey:[NSString stringWithFormat:@"%d", z]] objectForKey:@"items"] count] < 1){
                    [days removeObjectForKey:[NSString stringWithFormat:@"%d", z]];
                }
            }
            
            // Send back the resulting NSDictionary
            result.data = @{
                            @"week_timestamp": weekStartUnix,
                            @"days": days
                            };
            callback(result);
        }else{
            callback(result);
        }
    }];
}

@end
