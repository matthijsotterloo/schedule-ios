//
//  AppDelegate.h
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCalendarViewController.h"
#import "LoginViewController.h"
#import "SSSchoolViewController.h"
#import "SSDataProvider.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) SSCalendarViewController *controller;
@property (strong, nonatomic) UIViewController *schoolController;

@property (nonatomic) double cellSize;
@property (nonatomic) double smallCellSize;

@property (retain) SAUserObject *user;

- (void)getUser;
- (void)login:(BOOL)animated;
- (void)logout;

@end

