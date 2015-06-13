//
//  SSDataProvider.m
//  
//
//  Created by Thomas Schoffelen on 13/06/15.
//
//

#import "SSDataProvider.h"

@implementation SSDataProvider

static SAUserObject *userProfile;
static BOOL manualreset;

- (id) init {
    self.endPoint = @"https://api.lesrooster.io/";
    
    return [super init];
}

- (id) initWithProvider:(NSString*) provider {
    id ss = [self init];
    
    self.provider = provider;
    return ss;
}

- (BOOL) getSession {
    
    // Provider already set
    if(self.provider){
        return YES;
    }
    
    // Scholica access token set
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScholicaAccessToken"];
    if(accessToken) {
        [[Scholica instance] setAccessToken:accessToken];
        self.provider = @"scholica";
        NSLog(@"Utilizing existing SCHOLICA session");
        return YES;
    }

    // Provider credentials set
    NSString *providerType = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScheduleProviderType"];
    if (providerType) {
        NSLog(@"Utilizing existing PROVIDER[%@] session", providerType);
        self.provider = providerType;
        self.site = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScheduleProviderSite"];
        self.username = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScheduleProviderUsername"];
        self.password = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScheduleProviderPassword"];
        return YES;
    }
    
    NSLog(@"No exisiting session found");
    return NO;
}

- (void) saveSession {
    if(![self.provider isEqualToString:@"scholica"]){
        [[NSUserDefaults standardUserDefaults] setObject:self.provider forKey:@"ScheduleProviderType"];
        [[NSUserDefaults standardUserDefaults] setObject:self.site forKey:@"ScheduleProviderSite"];
        [[NSUserDefaults standardUserDefaults] setObject:self.username forKey:@"ScheduleProviderUsername"];
        [[NSUserDefaults standardUserDefaults] setObject:self.password forKey:@"ScheduleProviderPassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void) signOut {
    if ([self.provider isEqualToString:@"scholica"]) {
        [[Scholica instance] signOut];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScheduleProviderType"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScheduleProviderSite"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScheduleProviderUsername"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScheduleProviderPassword"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.provider = nil;
        self.username = nil;
        self.password = nil;
        self.site = nil;
        userProfile = nil;
    }
}

- (void) setProvider:(NSString *)provider site:(NSString *)site username:(NSString *)username password:(NSString *)password {
    self.provider = provider;
    self.site = site;
    self.username = username;
    self.password = password;
    manualreset = YES;
}

- (NSString*) getPersonURLString:(NSString*)method {
    return [NSString stringWithFormat:@"%@%@/%@/%@/%@/%@", self.endPoint, self.provider, self.site, self.username, self.password, method];
}

- (NSURL*) getPersonURL:(NSString*)method {
    return [NSURL URLWithString:[self getPersonURLString:method]];
}

- (void) personRequest:(NSString*)method callback:(SARequestCallback)callback {
    [SAJSONRequest request:[self getPersonURLString:method] parameters:@{} callback:callback];
}

- (void) profile:(SAProfileCallback)callback {
    if ([self.provider isEqualToString:@"scholica"]) {
        [[Scholica instance] profile:callback];
    }else{
        if(userProfile){
            callback(userProfile);
        }else{
            NSLog(@"Trying to get user");
            [self personRequest:@"user" callback:^(SARequestResult *result) {
                if(result.status == SARequestStatusOK){
                    if(manualreset){
                        manualreset = NO;
                        [self saveSession];
                    }
                    SAUserObject *user = [[SAUserObject alloc] init];
                    user.name = [result.data objectForKey:@"name"];
                    user.username = [result.data objectForKey:@"username"];
                    user.community = 99999;
                    user.picture = [self getPersonURL:@"picture"];
                    userProfile = user;
                    callback(user);
                }else{
                    SAUserObject *user = nil;
                    user.error = result.error;
                    callback(user);
                }
            }];
        }
    }
}

- (void)getSchoolsForProvider:(NSString*)provider searchText:(NSString*)searchText controller:(SSSchoolViewController*)controller {
    NSString* searchURL;
    if ([provider isEqualToString:@"magister"]) {
        searchURL = [NSString stringWithFormat:@"https://mijn.magister.net/api/schools?filter=%@", searchText];
    }
    
    [SAJSONRequest request:searchURL parameters:@{} callback:^(SARequestResult *result) {
        NSMutableArray* items = [[NSMutableArray alloc] init];
        for (NSDictionary* school in result.data) {
            NSString* schoolURLString = [school objectForKey:@"Url"];
            NSURL* schoolURL = [NSURL URLWithString:schoolURLString];
            NSArray * hostComponents = [[schoolURL host] componentsSeparatedByString:@"."];
            [items addObject:@{
                              @"title": [school objectForKey:@"Name"],
                              @"site": [hostComponents objectAtIndex:0]
                               }];
        }
        
        [controller setResults:items];
    }];
}

- (void)getCalendarWithTimestamp:(NSNumber*)time callback:(SARequestCallback)callback {
    if ([self.provider isEqualToString:@"scholica"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[Scholica instance] request:[NSString stringWithFormat:@"/communities/%d/calendar/schedule", appDelegate.user.community] withFields:@{@"time":time, @"show_week":@1, @"show_tasks":@0} callback:callback];
    }else{
        [self personRequest:[NSString stringWithFormat:@"meetings/%@", time == 0 ? @"now" : time] callback:callback];
    }
    
}

@end
