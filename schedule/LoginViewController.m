//
//  LoginViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "LoginViewController.h"
#import "SSSchoolViewController.h"
#import "SSWebLoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.services = @[
                      @"Scholica",
                      @"Magister",
                      @"SOMtoday ELO",
                      @"UvA rooster"
                      ];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.929 green:0.290 blue:0.392 alpha:1];
    
    [self.loginLabel setText:NSLocalizedString(@"SIGN IN TO VIEW YOUR SCHEDULE", nil)];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self services] objectAtIndex:indexPath.row];
    
    switch(indexPath.row){
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"icon-scholica"];
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"icon-magister"];
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"icon-somtoday"];
            break;
        case 3:
            cell.imageView.image = [UIImage imageNamed:@"icon-uva"];
            break;
            
    }
    
    cell.separatorInset = UIEdgeInsetsZero;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        cell.preservesSuperviewLayoutMargins = false;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self services] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch(indexPath.row) {
        case 0: {
            // Scholica
            [self loginWithScholica];
            break;
        }
        case 1: {
            // Magister
            SSSchoolViewController* controller = (SSSchoolViewController*)[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier: @"SelectSchool"];
            controller.provider = @"magister";
            appDelegate.schoolController = controller;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 2: {
            // SOMtoday ELO
            SSSchoolViewController* controller = (SSSchoolViewController*)[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier: @"SelectSchool"];
            controller.provider = @"somtoday";
            appDelegate.schoolController = controller;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 3: {
            // UvA
            SSWebLoginViewController* controller = (SSWebLoginViewController*)[appDelegate.mainStoryboard instantiateViewControllerWithIdentifier: @"WebLogin"];
            controller.provider = @"uva";
            appDelegate.schoolController = controller;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

@end
