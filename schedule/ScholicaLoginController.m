//
//  ScholicaLoginController.m
//  Created by Tom Schoffelen on 21-04-14.
//

#import "ScholicaLoginController.h"

@interface ScholicaLoginController ()

@end

@implementation NSString (NSString_Extended)

- (NSString *)urlencode {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
}

@end

@implementation ScholicaLoginController

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
    NSString* authURL = [NSString stringWithFormat:@"%@/auth?consumer_key=%@&redirect_uri=%@&mode=IOS", self.endPoint, [self.consumerKey urlencode], [self.redirectUri urlencode]];
    
    // Fire up webview
    [self.activityIndicator startAnimating];
    NSURLRequest *authRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:authURL]];
    [self.modalView loadRequest:authRequest];
}

- (void) viewDidAppear:(BOOL)animated {
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
        self.status = ScholicaLoginStatusNetworkError;
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
            [urlString rangeOfString:self.redirectUri].location != NSNotFound &&
            [urlString rangeOfString:[NSString stringWithFormat:@"redirect_uri=%@",[self.redirectUri urlencode]]].location == NSNotFound
            ){
            if(self.customLoginProcess){
                // custom login process, so open URL in Safari
                [[UIApplication sharedApplication] openURL:url];
            
            }else{
                // otherwise we will parse the result
                self.status = ScholicaLoginStatusUnknown;
                if([urlString rangeOfString:@"access_token="].location != NSNotFound){
                    self.accessToken = [[urlString componentsSeparatedByString:@"="] lastObject];
                    if(![self.accessToken isEqual:@""]){
                        self.status = ScholicaLoginStatusOK;
                    }
                }else if([urlString rangeOfString:@"access_error=invalid_consumer"].location != NSNotFound){
                    self.status = ScholicaLoginStatusInvalidConsumer;
                }else if([urlString rangeOfString:@"access_error=canceled_by_user"].location != NSNotFound){
                    self.status = ScholicaLoginStatusCanceledByUser;
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
