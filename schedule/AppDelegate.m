//
//  AppDelegate.m
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "AppDelegate.h"
#import "iRate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void) initialize {
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 7;
}

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set Scholica consumer key & secret
    [[Scholica instance] setConsumerKey:@"a62weE1HRXdOVWRXV0d4VVYwZWRWRmw0ZEhk561WcHpWMjFHVjJKR2JETl666Up3"];
    [[Scholica instance] setConsumerSecret:@"2lSMmhXVm14a2IxSkdj7f9a4jBaVVVsUldXbGRyWkc5VWJVVjRZMFZvVjFKc2NGaFdha1po4WpGa4NsZHNV4WxTVlhCd4ZtM"];
    
    // Set appearance
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"ProximaNova-Regular" size:17], NSFontAttributeName, [UIColor colorWithWhite:0.2 alpha:1.0],NSForegroundColorAttributeName, nil]];
    
    // BackButton appearance
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:17]} forState:UIControlStateNormal];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage alloc] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage alloc]];
    
    // Set up view controllers
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    self.controller = (SSCalendarViewController*)[self.mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
    [self setupNavigationController];
    
    // Check if user is signed in
    if(![[SSDataProvider instance] getSession]){
        // Show login screen
        [self login:NO];
    }else{
        // Start app
        [self getUser];
    }
    
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if(![[Scholica instance] applicationDelegateOpenURL:url sourceApplication:sourceApplication]){
        // Override point for URL scheme handling if requested URL is not related to Scholica login
    }
    
    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
    if(self.user && self.controller){
        [self.controller synchronize];
    }else if(self.controller && [[SSDataProvider instance] getSession]){
        [self getUser];
    }
}


# pragma mark - View controller setup

- (void) setupNavigationController {
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.6 alpha:1.0]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.navigationController.navigationBar.frame.size.width, 22)];
    statusBarView.backgroundColor = [UIColor whiteColor];
    statusBarView.tag = 999;
    [self.navigationController.navigationBar addSubview:statusBarView];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.navigationController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
}


# pragma mark - Scholica authentication

- (void) login:(BOOL)animated {
    // Present login overlay
    LoginViewController *vc = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    [self.navigationController presentViewController:vc animated:animated completion:nil];
}

- (void) logout {
    // Destroy access token
    [[SSDataProvider instance] signOut];
    
    // Remove cache files
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error = nil;
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error]) {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
    }
    
    // Show login dialog
    [self login:YES];
}

- (void) getUser {
    [[SSDataProvider instance] profile:^(SAUserObject *user) {
        if(user && !user.error){
            // Got user data, save it and start synchronisation
            self.user = user;
            
            // Synchronize data
            if(self.controller) {
                [self.controller synchronize];
            }
        }else if(user.error.code > 400 && user.error.code != 500){
            // Show login dialog, but only if the error is a user-related error, not a network error
            NSLog(@"Login error, present login view.");
            if(([[SSDataProvider instance].provider isEqual: @"magister"] || [[SSDataProvider instance].provider isEqual: @"somtoday"]) && [SSDataProvider instance].site){
                [SSDataProvider invokeLoginDialogForProvider:[SSDataProvider instance].provider site:[SSDataProvider instance].site title:@"Sign in"];
            }else{
                [self login:YES];
            }
        }else{
            // Network error, so try again in a couple of seconds
            NSLog(@"Network error, will try again soon.");
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getUser) userInfo:nil repeats:NO];
        }
    }];
}

@end
