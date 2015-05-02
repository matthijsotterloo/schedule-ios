# Scholica SDK for iOS

An iOS SDK to allow an easy implementation of the Scholica API into your apps and allow users to login with and save data to Scholica. 

[![Build Status](https://travis-ci.org/scholica/sdk-ios.png)](https://travis-ci.org/scholica/sdk-ios)

## Installation
You can install the Scholica SDK by using [CocoaPods](https://github.com/CocoaPods/CocoaPods) or manually downloading the SDK files.

### CocoaPods

Add the following to your `Podfile`:

	pod 'Scholica'


### Manually

Simply drag all the files in the `Scholica` directory into your Xcode project.

Import the Scholica header and you're kickin' ass:

    #import "Scholica.h"


## Implementation example

If you need a sample implementation for reference, please take a look at the [schedule-ios](https://github.com/scholica/schedule-ios) project. Especially the [login controller there](https://github.com/scholica/schedule-ios/blob/master/schedule/LoginViewController.m#L42) might be worth a look.


## Getting started

### 1. Setting up your .plist
When a user has the Scholica app installed, the Scholica SDK will attempt to sign in using the native login interface. To set this up, you need to add a URL scheme to your `.plist` file. Create an array key called URL types with a single array sub-item called URL Schemes. Give this a single item with your full consumer key.

This is used to ensure the application will receive the callback URL of the sign in flow.

Your `.plist` should look like this:

![Plist example](InfoPlistExample.png)


### 2. Add your consumer key and secret

Initiate Scholica by setting your Consumer key and secret. It is usually best to do this in the `application:didFinishLaunchingWithOptions:` method in your AppDelegate.

	[[Scholica instance] setConsumerKey:@"<CONSUMERKEY>"];
    [[Scholica instance] setConsumerSecret:@"<CONSUMERSECRET>"];

Please request a consumer key and consumer secret for your application by sending an email to [support@scholica.com](mailto:support@scholica.com).

### 3. Adding a `openURL` callback

Scholica will use the URL scheme you set up to redirect back to your app after a successful or failed authentication attempt. To handle this request, make sure the `openURL` method in your AppDelegate looks like this:

	- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	    
	    if(![[Scholica instance] applicationDelegateOpenURL:url sourceApplication:sourceApplication]){
	        // Override point for URL scheme handling if requested URL is not related to Scholica login
	    }
	    
	    return YES;
	    
	}
	

### 4. Signing in

The interesting part. Use `[[Scholica instance] currentSession]` to evaluate if the user is already signed in (using information from NSUserDefaults) and otherwise call the `signIn` method:

	if([[Scholica instance] currentSession]){
		
		// User is logged in, do work such as go to next view controller.
		
	}else{
		
		// Call signIn method
		[[Scholica instance] signIn:^(SALoginStatus status) {
        	NSLog(@"Successful sign in!");
	    } failure:^(SALoginStatus status) {
	        NSLog(@"Something went wrong...");
	    }];
	
	}

After a successful or failed login, respectively the `success` or `failure` methods will be called. Both are of type `ScholicaLoginCallback` and accept a single argument: an enum of type `SALoginStatus`, which is equal to one of these values:

* SALoginStatusOK
* SALoginStatusInvalidConsumer
* SALoginStatusCanceledByUser
* SALoginStatusNetworkError
* SALoginStatusUnknown

When the login was successful, the Scholica object will contain the variable `accessToken`, which is automatically saved to NSUserDefaults by `SASession`. To disable this behaviour and manually save the access token for reuse, set `autoSaveAccessToken` to NO:

	[[Scholica instance] setAutoSaveAccessToken:NO];


### 5. Getting the user's profile

Call the `profile` method to receive information about the current user:

	[[Scholica instance] profile:^(SAUserObject *user) {
        NSLog(@"Hi %@, welcome!", user.name);
    }];
    
On failure, `user` will be `nil`.


### 6. Sending API requests

Call the `request` method:

	[scholica request:@"/communities/1" callback:^(SARequestResult *result) {
        if(result.status == SARequestStatusOK){
            // Request was successful
            NSLog(@"The title of this community is %@!", [result.data objectForKey:@"title"]);

        }else if(result.error.code > 900){
            // Scholica error
            NSLog(@"Scholica error: ", result.error.errorDescription);

        }else{
            // Network error
            NSLog(@"Network error.");
        }
    }];

Doing API requests (to the [methods described here](http://help.scholica.com/developers/API/methods)) is as simple as setting a method (i.e. `/me`), optionally a number of parameters in the NSDictionary `fields` and a callback, which accepts one parameter of the type `ScholicaRequestResult`, which contains:

* `status` - A `SARequestStatus` enum with value SARequestStatusOK or SARequestStatusError
* `data` - A `NSDictionary` with the API result, when the status is SARequestStatusOK
* `error` - An `SARequestError` object, when the status is SARequestStatusError (attributes: code, errorDescription, documentationURL)

## Class reference

For more information, refer to the [SDK class reference](http://scholica-ref-ios.surge.sh/).