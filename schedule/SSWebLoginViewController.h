//
//  SSWebLoginViewController.h
//  schedule
//
//  Created by Thomas Schoffelen on 29/08/2015.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMMaterialDesignSpinner.h"

@interface SSWebLoginViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView* webView;
@property (nonatomic, strong) NSString* provider;

@property (nonatomic, strong) MMMaterialDesignSpinner* spinner;

@end
