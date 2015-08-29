
//
//  SSCreditsViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 29/08/2015.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SSCreditsViewController.h"

@interface SSCreditsViewController ()

@end

@implementation SSCreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CATransition* transition = [CATransition alloc];
    transition.type = kCATransitionFade;
    transition.duration = 0.12;
    [self.navigationController.navigationBar.layer addAnimation:transition forKey:nil];
    [[self.navigationController.navigationBar viewWithTag:999].layer addAnimation:transition forKey:nil];
    
    [self.navigationController.navigationBar viewWithTag:999].alpha = 0;
    [self.navigationController.navigationBar setBackgroundColor:[UIColor colorWithRed:1 green:0.92 blue:0.48 alpha:1]];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    CATransition* transition = [CATransition alloc];
    transition.type = kCATransitionFade;
    transition.duration = 0.12;
    [self.navigationController.navigationBar.layer addAnimation:transition forKey:nil];
    [[self.navigationController.navigationBar viewWithTag:999].layer addAnimation:transition forKey:nil];
    
    [self.navigationController.navigationBar viewWithTag:999].alpha = 1;
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
