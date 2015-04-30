//
//  AppDelegate.m
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize navigationController;
@synthesize mainStoryboard;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    self.controller = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
    [navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"ProximaNova-Regular" size:17], NSFontAttributeName, [UIColor colorWithWhite:0.2 alpha:1.0],NSForegroundColorAttributeName, nil]];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, navigationController.navigationBar.frame.size.width, 22)];
    statusBarView.backgroundColor = [UIColor whiteColor];
    [navigationController.navigationBar addSubview:statusBarView];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:navigationController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [self.window makeKeyAndVisible];
    
    self.scholica = [[Scholica alloc] initWithConsumerKey:@"262weE1HRXdOVWRXV0d4VVYwZWRWRmw0ZEhk561WcHpWMjFHVjJKR2JETl666Up3" secret:@"2lSMmhXVm14a2IxSkdj7f9a4jBaVVVsUldXbGRyWkc5VWJVVjRZMFZvVjFKc2NGaFdha1po4WpGa4NsZHNV4WxTVlhCd4ZtM"];
    
    // Check if access token is available
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"ScholicaAccessToken"];
    if(!accessToken){
        // Show login screen
        [self login:YES];
    }else{
        // Set access token
        self.scholica.accessToken = accessToken;
        [self getUser];
    }
    
    return YES;
}

- (void)login:(BOOL)animated {
    LoginViewController *vc = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    [self.navigationController presentViewController:vc animated:NO completion:nil];
}

- (void)logout {
    // Remove access token
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ScholicaAccessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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

- (void)getUser {
    NSLog(@"Getting user...");
    
    [self.scholica request:@"/me" callback:^(ScholicaRequestResult *result) {
        if(result.status == ScholicaRequestStatusOK){
            // Got user data, save it and start synchronisation
            self.user = result.data;
            
            // Synchronize data
            if(self.controller) {
                [self.controller synchronize];
            }
        }else if(result.error.code > 900){
            // Show login dialog, but only if the error is a Scholica error, not a network error
            NSLog(@"Scholica error, present login view.");
            [self login:YES];
        }else{
            // Network error, so try again in a couple of seconds
            NSLog(@"Network error, will try again soon.");
            [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getUser) userInfo:nil repeats:NO];
        }
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if(self.user && self.controller){
        [self.controller synchronize];
    }else if(self.controller && self.scholica.accessToken){
        [self getUser];
    }
}

@end
