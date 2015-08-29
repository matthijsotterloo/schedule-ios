//
//  LoginViewController.h
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scholica.h"

@interface LoginViewController : UIViewController <UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *loginLabel;

@property (strong, atomic) NSArray* services;

@end