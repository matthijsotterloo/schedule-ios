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
static NSArray* schoolsList;

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
    [self JSONRequest:[self getPersonURLString:method] callback:callback];
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
                    SAUserObject *user = [[SAUserObject alloc] init];
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
        if ([searchText length] < 3) {
            return;
        }
    }
    
    if([provider isEqual:@"somtoday"]){
        searchURL = @"inline-search";
    }
    
    if(searchURL){
        if([searchURL isEqual:@"inline-search"]){
            NSMutableArray* items = [[NSMutableArray alloc] init];
            for(NSDictionary* school in schoolsList){
                if ([searchText length] == 0 || [[school objectForKey:@"title"] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [items addObject:school];
                }
            }
            [controller setSearchResults:items];
        }else{
            [self JSONRequest:searchURL callback:^(SARequestResult *result) {
                NSMutableArray* items = [[NSMutableArray alloc] init];
                if (result.status == SARequestStatusOK) {
                    for (NSDictionary* school in result.data) {
                        NSString* schoolURLString = [school objectForKey:@"Url"];
                        NSURL* schoolURL = [NSURL URLWithString:schoolURLString];
                        NSArray * hostComponents = [[schoolURL host] componentsSeparatedByString:@"."];
                        [items addObject:@{
                            @"title": [school objectForKey:@"Name"],
                            @"site": [hostComponents objectAtIndex:0]
                        }];
                    }
                }
                [controller setSearchResults:items];
            }];
        }
    }
}

- (void)prefillListForProvider:(NSString*)provider controller:(SSSchoolViewController*)controller {
    NSString* searchURL;
    schoolsList = @[];
    
    if ([provider isEqualToString:@"somtoday"]) {
        searchURL = @"https://servers.somtoday.nl/";
    }
    
    if(searchURL) {
        [self JSONRequest:searchURL callback:^(SARequestResult *result) {
            NSMutableArray* items = [[NSMutableArray alloc] init];
            if (result.status == SARequestStatusOK) {
                NSArray* resdata = result.data;
                NSArray* schools = [[resdata objectAtIndex:0] objectForKey:@"instellingen"];
                for (NSDictionary* school in schools) {
                    [items addObject:@{
                       @"title": [school objectForKey:@"naam"],
                       @"site": [NSString stringWithFormat:@"%@-%@", [school objectForKey:@"afkorting"], [school objectForKey:@"brin"]]
                    }];
                }
            }
            schoolsList = items;
            [controller setSearchResults:items];
        }];
    }else{
        NSMutableArray* items = [[NSMutableArray alloc] init];
        [controller setSearchResults:items];
    }
}

- (void)getCalendarWithTimestamp:(NSNumber*)time callback:(SARequestCallback)callback {
    if ([self.provider isEqualToString:@"scholica"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[Scholica instance] request:[NSString stringWithFormat:@"/communities/%d/calendar/schedule", appDelegate.user.community] withFields:@{@"time":time, @"show_week":@1, @"show_tasks":@0} callback:callback];
    }else{
        [self personRequest:[NSString stringWithFormat:@"meetings/%@", time == 0 ? @"now" : time] callback:callback];
    }
    
}

- (void)getGrades:(SARequestCallback)callback {
        [self personRequest:[NSString stringWithFormat:@"grades/"] callback:callback];
}

- (void)getHomework:(SARequestCallback)callback {
    [self personRequest:[NSString stringWithFormat:@"meetings/now"] callback:callback];
}


- (void) JSONRequest:(NSString *)url callback:(SARequestCallback)callback {
    
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:[Scholica instance].requestTimeout];
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
               
               // JSON array fix
               if (result.status == SARequestStatusError &&
                   [result.error.errorDescription isEqualToString:@"Response is no valid JSON"]) {
                   NSError* errorObject;
                   @try {
                       NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&errorObject];
                       result.data = array;
                       result.status = SARequestStatusOK;
                       result.error = nil;
                   }
                   @catch(NSException* exception){
                       result.data = @{};
                       result.status = SARequestStatusError;
                       result.error = [[SARequestError alloc] initWithData:@{
                           @"code": @"999",
                           @"description": @"Response is no valid JSON",
                           @"documentation": @""
                       }];
                   }
               }else if([result.data objectForKey:@"provider_error"]){
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

+ (void)invokeLoginDialogForProvider:(NSString*)provider site:(NSString*)site title:(NSString*)title {
    [SSDataProvider instance].provider = provider;
    [SSDataProvider instance].site = site;
    UIAlertView* alert =[[UIAlertView alloc] initWithTitle:title message:[NSString stringWithFormat:@"Sign in to %@", provider] delegate:[SSDataProvider instance] cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alert addButtonWithTitle:@"Login"];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (buttonIndex == 1) {
        NSString* username = [alertView textFieldAtIndex:0].text;
        NSString* password = [alertView textFieldAtIndex:1].text;
        if([username isEqual:@""] || [password isEqual:@""]){
            [SSDataProvider invokeLoginDialogForProvider:self.provider site:self.site title:@"Sign in"];
            return;
        }
        
        [self setProvider:self.provider site:self.site username:username password:password];
        
        [appDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
        appDelegate.schoolController = nil;
        [appDelegate getUser];
    }else{
        LoginViewController *vc = [appDelegate.mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
        if(appDelegate.schoolController){
            [appDelegate.schoolController presentViewController:vc animated:NO completion:nil];
        }else{
            [appDelegate.navigationController presentViewController:vc animated:NO completion:nil];
        }
    }
}

@end
