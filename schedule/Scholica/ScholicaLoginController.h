//
//  ScholicaLoginController.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScholicaConstants.h"

@interface ScholicaLoginController : UIViewController
<UIWebViewDelegate>

@property (nonatomic) NSString* redirectUri;
@property (nonatomic) NSString* consumerKey;
@property (nonatomic) NSString* endPoint;
@property (nonatomic) BOOL customLoginProcess;
@property (nonatomic) BOOL shouldHide;

@property (nonatomic) ScholicaLoginStatus status;
@property (nonatomic) NSString* accessToken;
@property (nonatomic, copy) ScholicaLoginControllerCallback callback;

@property (nonatomic, retain) UIWebView* modalView;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;

@end
