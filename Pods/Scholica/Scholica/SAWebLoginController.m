//
//  SALoginController.m
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SAWebLoginController.h"

@interface SAWebLoginController ()

@end

@implementation SAWebLoginController

+ (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure viewController:(UIViewController *)viewController {
    // Create a view controller (SALoginController)
    SAWebLoginController *loginController = [[SAWebLoginController alloc] init];
    
    // Set redirect URI
    loginController.redirectURI = @"webview://x-callback-url/auth";
    
    // Set callbacks
    __block SAWebLoginController* loginControllerShim = loginController;
    loginController.callback = ^{
        if(loginControllerShim.status == SALoginStatusOK){
            NSString *accessToken = loginControllerShim.accessToken;
            [Scholica instance].accessToken = accessToken;
            if([[Scholica instance] autoSaveAccessToken]){
                [SASession saveAccessToken:accessToken];
            }
            success(loginControllerShim.status);
        }else{
            failure(loginControllerShim.status);
        }
        
        if (![Scholica instance].customDismissLoginController){
            [viewController dismissViewControllerAnimated:YES completion:nil];
            loginControllerShim.shouldHide = YES;
        }
    };
    
    // Present view controller
    loginController.shouldHide = NO;
    [viewController presentViewController:loginController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up webview
    self.modalView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.modalView.delegate = self;
    self.modalView.backgroundColor = [UIColor blackColor];
    self.modalView.scrollView.bounces = NO;
    [self.view addSubview:self.modalView];
    
    // Set up activityIndicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.frame = self.modalView.frame;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    // Compile authorization URL
    NSString* authURL = [NSString stringWithFormat:@"%@/auth?consumer_key=%@&redirect_uri=%@&mode=IOS", [Scholica instance].authEndPoint, [SAUtilities urlencode:[Scholica instance].consumerKey], [SAUtilities urlencode:self.redirectURI]];
    
    // Fire up webview
    [self.activityIndicator startAnimating];
    NSURLRequest *authRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
    [self.modalView loadRequest:authRequest];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.shouldHide){
        [self dismissViewControllerAnimated:YES completion:nil];
        self.shouldHide = NO;
    }
}

- (void) webViewDidFinishLoad:(UIWebView*)webView {
    if(webView == self.modalView){
        [self.activityIndicator stopAnimating];
    }
}

- (void) webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    if(webView == self.modalView){
        [self.activityIndicator stopAnimating];
        self.status = SALoginStatusNetworkError;
        [self complete];
    }
}

- (void) complete
{
    [self.modalView stopLoading];
    [self.activityIndicator stopAnimating];
    self.modalView.delegate = nil;
    self.callback();
    self.callback = ^{};
}

- (BOOL) webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.modalView){
        
        NSURL *url = request.URL;
        NSString *urlString = url.absoluteString;
        
        if (
            [urlString rangeOfString:self.redirectURI].location != NSNotFound &&
            [urlString rangeOfString:[NSString stringWithFormat:@"redirect_uri=%@",[SAUtilities urlencode:self.redirectURI]]].location == NSNotFound
            ){
            if([Scholica instance].customLoginProcess){
                // custom login process, so open URL in Safari
                [[UIApplication sharedApplication] openURL:url];
            }else{
                // otherwise we will parse the result
                self.status = SALoginStatusUnknown;
                if([urlString rangeOfString:@"access_token="].location != NSNotFound){
                    self.accessToken = [[urlString componentsSeparatedByString:@"="] lastObject];
                    if(![self.accessToken isEqual:@""]){
                        self.status = SALoginStatusOK;
                    }
                }else if([urlString rangeOfString:@"access_error=invalid_consumer"].location != NSNotFound){
                    self.status = SALoginStatusInvalidConsumer;
                }else if([urlString rangeOfString:@"access_error=canceled_by_user"].location != NSNotFound){
                    self.status = SALoginStatusCanceledByUser;
                }
                [self complete];
            }
            
            return NO;
        }
        
        [self.activityIndicator startAnimating];
    }
    
    return YES;
}

@end
