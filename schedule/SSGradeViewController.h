//
//  SSGradeViewController.h
//  schedule
//
//  Created by Thomas Schoffelen on 28/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentTableView.h"
#import "LoginViewController.h"

#import "Scholica.h"

@interface SSGradeViewController : UIViewController <SubTableViewDelegate, SubTableViewDataSource, UIAlertViewDelegate, ParentTableViewDelegate>

- (void) synchronize;

@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) IBOutlet ParentTableView *tableView;
@property (strong, nonatomic) UIImageView *footericon;

@end