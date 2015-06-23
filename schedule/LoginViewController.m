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
    
    [self.loginButton setTitle:NSLocalizedString(@"CHOOSE ACCOUNT", nil) forState:UIControlStateNormal];
    [self.loginLabel setText:NSLocalizedString(@"SIGN IN TO VIEW YOUR SCHEDULE, HOMEWORK AND GRADES", nil)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) loginButtonTapped:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"Choose account", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Scholica", @"Magister", @"SomToday", nil];
    [actionSheet showInView:self.view];
}

- (void) loginWithScholica
{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    [[Scholica instance] signIn:^(SALoginStatus status){
        NSLog(@"Login success");
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

        [[SSDataProvider instance] setProvider:@"scholica"];
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [appDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
        [appDelegate getUser];
        }
    failure:^(SALoginStatus status){
        NSLog(@"Login fail");
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

        if(status == SALoginStatusInvalidConsumer){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                            message: @"The application is not correctly configured for signing in with Scholica."
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if(status == SALoginStatusNetworkError){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                            message: @"Please check your internet connection and try signing in again."
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if(status == SALoginStatusUnknown){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Login error"
                                                            message: @"An unknown error occurred. Please try signing in again."
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } viewController:self];
    
    NSLog(@"Logging in...");
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if([buttonTitle isEqualToString:@"Magister"]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        SSSchoolViewController* controller = (SSSchoolViewController*)[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier: @"SelectSchool"];
        controller.provider = @"magister";
        appDelegate.schoolController = controller;
        [self showDetailViewController:controller sender:nil];
    }else if([buttonTitle isEqualToString:@"SomToday"]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        SSSchoolViewController* controller = (SSSchoolViewController*)[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier: @"SelectSchool"];
        controller.provider = @"somtoday";
        appDelegate.schoolController = controller;
        [self showDetailViewController:controller sender:nil];
    }else if([buttonTitle isEqualToString:@"Scholica"]){
        [self loginWithScholica];
    }
}

@end
