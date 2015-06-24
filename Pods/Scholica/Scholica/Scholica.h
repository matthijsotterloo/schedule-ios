//
//  Scholica.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import "SAConstants.h"
#import "SASingleton.h"
#import "SAJSONRequest.h"
#import "SASession.h"
#import "SAWebLoginController.h"
#import "SANativeLoginController.h"
#import "SARequestResult.h"
#import "SARequestError.h"
#import "SAUtilities.h"
#import "SAUserObject.h"

@interface Scholica : SASingleton

/** ---------------------------------------------------------------------------------------
 * @name Setup
 *  ---------------------------------------------------------------------------------------
 */

/** 
  Set the consumer key
  @param consumerKey Your consumer key
 */
- (void) setConsumerKey:(NSString *)consumerKey;

/**
 Set the consumer secret
 @param consumerSecret Your consumer secret
 */
- (void) setConsumerSecret:(NSString *)consumerSecret;


/** ---------------------------------------------------------------------------------------
 * @name Sessions
 *  ---------------------------------------------------------------------------------------
 */

/**
 Bring up a sign in dialog (either native through the Scholica app or via a WebView
 @param success Success callback, single parameter of type SALoginStatus
 @param failure Failure callback, single parameter of type SALoginStatus
 */
- (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure;

/**
 Bring up a sign in dialog (either native through the Scholica app or via a WebView
 @param success Success callback, single parameter of type SALoginStatus
 @param failure Failure callback, single parameter of type SALoginStatus
 @param viewController Reference to the viewController upon which the login webview should appear
 */
- (void) signIn:(SALoginCallback)success failure:(SALoginCallback)failure viewController:(UIViewController *)viewController;

/**
 Checks whether an access token is currently available in the Scholica SDK
 @return Boolean to indicate if the SDK class is ready to handle requests
 */
- (BOOL) currentSession;

/**
 Signs the user out by removing the access token from NSDefaults and 
 sending a destroy request to the Scholica API
 */
- (void) signOut;


/** ---------------------------------------------------------------------------------------
 * @name Tokens
 *  ---------------------------------------------------------------------------------------
 */

/**
 Generate a request token for the current access token
 
 The actual request token that is generated won't be passed onto the callback
 function directory, but is rather immeadiately inserted into the Scholica class,
 and available through `[Scholica instance].requestToken`.
 
 @param callback A callback function, single parameter of type SARequestResult
 */
- (void) getRequestToken:(SARequestCallback)callback;


/** ---------------------------------------------------------------------------------------
 * @name Perform requests
 *  ---------------------------------------------------------------------------------------
 */

 /**
 Send an API request to a specific method

 @param method API method to call, ie. `/me` or `/communities/1`
 @param fields Dictionary of POST fields to send
 @param callback Callback function with single parameter of type SARequestResult
 */
- (void) request:(NSString*)method withFields:(NSDictionary*)fields callback:(SARequestCallback)callback;

 /**
 Send an API request to a specific method

 @param method API method to call, ie. `/me` or `/communities/1`
 @param callback Callback function with single parameter of type SARequestResult
 */
- (void) request:(NSString*)method callback:(SARequestCallback)callback;


/** ---------------------------------------------------------------------------------------
 * @name Specific requests
 *  ---------------------------------------------------------------------------------------
 */

 /**
 Retrieve the user's profile

 This method is a simple shell around request:callback:, where it requests the
 method /me and converts the request into a SAUserObject. Error checking can be
 done by ensuring that the `error` property of the SAUserObject is `nil`. 

 @param callback Callback function with single parameter of type SAUserObject
 */
 - (void) profile:(SAProfileCallback)callback;


/** ---------------------------------------------------------------------------------------
 * @name Delegate helper
 *  ---------------------------------------------------------------------------------------
 */

 /**
 Application delegate helper

 This method needs to be implemented into the ApplicationDelegate class to ensure
 correct functionality of the native sign in system.

 @param url Passed URL
 @param sourceApplication String with the Bundle ID of the source application
 */
- (BOOL) applicationDelegateOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/** ---------------------------------------------------------------------------------------
 * @name Properties
 *  ---------------------------------------------------------------------------------------
 */

/** Scholica API endpoint */
@property (nonatomic) NSString* endPoint;

/** Scholica authentication API endpoint */
@property (nonatomic) NSString* authEndPoint;

/** Consumer key */
@property (nonatomic) NSString* consumerKey;

/** Consumer secret */
@property (nonatomic) NSString* consumerSecret;

/** Whether to use an alternative login process */
@property (nonatomic) BOOL customLoginProcess;

/** Whether to disable the default way of dismissing the login controller */
@property (nonatomic) BOOL customDismissLoginController;

/** Access token */
@property (nonatomic) NSString* accessToken;

/** Request token */
@property (nonatomic) NSString* requestToken;

/** Timeout for requests, defaults to 30 seconds */ 
@property (nonatomic) NSInteger requestTimeout;

/** Whether to automatically save and load access tokens after successful logins */ 
@property (nonatomic) BOOL autoSaveAccessToken;

@end