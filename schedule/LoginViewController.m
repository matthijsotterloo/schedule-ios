//
//  LoginViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.929 green:0.290 blue:0.392 alpha:1];
    
    [self.loginButton setTitle:NSLocalizedString(@"SIGN IN WITH SCHOLICA", nil) forState:UIControlStateNormal];
    [self.loginLabel setText:NSLocalizedString(@"SIGN IN TO VIEW YOUR SCHEDULE", nil)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // TODO: remove this (DEBUGGING)
    //[self loginButtonTapped:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) loginButtonTapped:(id)sender
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    Scholica* scholica = appDelegate.scholica;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [scholica loginInViewController:self
                            success:^(ScholicaLoginStatus status){
                                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                                
                                [appDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
                                [[NSUserDefaults standardUserDefaults] setObject:scholica.accessToken forKey:@"ScholicaAccessToken"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                [appDelegate getUser];
                            }
                            failure:^(ScholicaLoginStatus status){
                                NSLog(@"Login failure...");
                                
                                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                                
                                if(status == ScholicaLoginStatusInvalidConsumer){
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                                                    message: @"The application is not correctly configured for signing in with Scholica."
                                                                                   delegate: nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil
                                                          ];
                                    [alert show];
                                }
                                if(status == ScholicaLoginStatusNetworkError){
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                                                    message: @"Please check your internet connection and try signing in again."
                                                                                   delegate: nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil
                                                          ];
                                    [alert show];
                                }
                                if(status == ScholicaLoginStatusUnknown){
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                                                    message: @"An unknown error occurred. Please try signing in again."
                                                                                   delegate: nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil
                                                          ];
                                    [alert show];
                                }
                                
                            }
     ];
    
    NSLog(@"Logging in...");
    
}

@end
