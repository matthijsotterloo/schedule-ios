//
//  SALoginController.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scholica.h"

@interface SAWebLoginController : UIViewController
<UIWebViewDelegate>

@property (nonatomic) NSString* redirectURI;
@property (nonatomic) BOOL shouldHide;

@property (nonatomic) SALoginStatus status;
@property (nonatomic) NSString* accessToken;
@property (nonatomic, copy) SALoginControllerCallback callback;

@property (nonatomic, retain) UIWebView* modalView;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;

+ (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure viewController:(UIViewController *)viewController;

@end
