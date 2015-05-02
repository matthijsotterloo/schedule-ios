//
//  AppDelegate.h
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scholica.h"
#import "ViewController.h"
#import "LoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) ViewController *controller;

@property (nonatomic) double cellSize;

@property (retain) SAUserObject *user;

- (void)getUser;
- (void)login:(BOOL)animated;
- (void)logout;

@end

