//
//  SSWebLoginViewController.m
//  schedule
//
//  Created by Thomas Schoffelen on 29/08/2015.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SSWebLoginViewController.h"
#import "SSDataProvider.h"

@interface SSWebLoginViewController ()

@end

@implementation SSWebLoginViewController

BOOL completed = NO;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    completed = NO;
    
    // Set up activityIndicator
    self.spinner = [[MMMaterialDesignSpinner alloc] init];
    self.spinner.frame = CGRectMake(self.webView.frame.size.width / 2 - 15, self.webView.frame.size.height / 2 - 15, 30, 30);
    self.spinner.hidesWhenStopped = YES;
    self.spinner.lineWidth = 1.5f;
    self.spinner.tintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    [self.view addSubview:self.spinner];
    
    // Compile authorization URL
    NSString* authURL = [NSString stringWithFormat:@"https://secure-apis.uva.nl/oauth2/authorize?client_id=myuva_app_prd&redirect_uri=http://localhost/oauth-callback&scope=read&response_type=token"];
    
    // Fire up webview
    [self.spinner startAnimating];
    NSURLRequest *authRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
    [self.webView loadRequest:authRequest];
}

- (void) viewDidDisappear:(BOOL)animated {
    completed = YES;
}

- (void) webViewDidFinishLoad:(UIWebView*)webView {
    if(webView == self.webView){
        if([self.provider isEqual: @"uva"]){
            NSString* css = @"div#header { background-position: 50% 0 !important;margin-top: 32px !important;padding-bottom: 66px !important;}div#header h1 {display: none !important;}#cas form {padding: 0 20px !important;margin: 0 !important;width: auto !important;}.fm-v div.row, #cas #login {float: none !important; width: auto !important; padding: 0 !important;margin: 0 !important;} #cas #login input { width: 100% !important; margin: 0 !important; margin-bottom: 24px !important;height: 34px !important; box-sizing: border-box !important; -webkit-box-sizing: border-box !important; float: none !important;} #cas #login label span.accesskey { text-decoration: none !important;}#cas #login label {font-family: \"Helvetica Neue\" !important; font-size: 15px !important; font-weight: normal !important; padding-bottom: 6px !important; float: none !important;clear: both;height: auto;}";
            NSString* js = [NSString stringWithFormat:
                            @"var styleNode = document.createElement('style');\n"
                            "var styleText = document.createTextNode('%@');\n"
                            "styleNode.appendChild(styleText);\n"
                            "document.getElementsByTagName('body')[0].appendChild(styleNode);document.getElementById('username').focus();\n",css];
            [self.webView stringByEvaluatingJavaScriptFromString:js];
        }
        [self.spinner stopAnimating];
    }
}

- (void) webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
    if(webView == self.webView){
        [self.spinner stopAnimating];
        if(!completed){
            NSLog(@"Webview error: %@", error);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:error.localizedDescription delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (BOOL) webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if(webView == self.webView){
        
        NSURL *url = request.URL;
        NSString *urlString = url.absoluteString;
        
        if (
            [urlString rangeOfString:@"http://localhost/oauth-callback"].location != NSNotFound &&
            [urlString rangeOfString:@"redirect_uri="].location == NSNotFound
        ){
            // otherwise we will parse the result
            NSString* accessToken = @"";
            if([urlString rangeOfString:@"access_token="].location != NSNotFound){
                accessToken = [[urlString componentsSeparatedByString:@"access_token="] lastObject];
                accessToken = [[accessToken componentsSeparatedByString:@"&"] firstObject];
                if(![accessToken isEqual:@""]){
                    completed = YES;
                    [[SSDataProvider instance] setProvider:self.provider site:nil username:nil password:accessToken];
                    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
                    [appDelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
                    [appDelegate getUser];
                    NSLog(@"Accesstoken: %@", accessToken);
                }
            }else{
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Sorry, could not sign in using this method." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
            return NO;
        }
        
        [self.spinner startAnimating];
    }
    
    return YES;
}


@end
