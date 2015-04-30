//
//  LoginViewController.h
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Scholica/Scholica.h>

@interface LoginViewController : UIViewController

- (IBAction) loginButtonTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UILabel *loginLabel;

@end