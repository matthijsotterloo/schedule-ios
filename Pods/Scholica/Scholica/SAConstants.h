//
//  SAContstants.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SARequestResult, SAUserObject;

typedef enum {
    SALoginStatusOK,                    // No problems here
    SALoginStatusInvalidConsumer,       // The supplied consumer_key is invalid or blocked
    SALoginStatusInvalidBundleId,       // The app requesting authorization is not registered for this consumer
    SALoginStatusInvalidAction,         // The requested resource is unavailable
    SALoginStatusCanceledByUser,        // The user canceled the login request
    SALoginStatusNetworkError,          // Network error (could not load frame)
    SALoginStatusUnknown                // Unknown error
} SALoginStatus;

typedef enum {
    SARequestStatusOK,                  // No problems here
    SARequestStatusError                // Error occurred
} SARequestStatus;

typedef void (^SALoginCallback) (SALoginStatus status);
typedef void (^SALoginControllerCallback) ();
typedef void (^SARequestCallback) (SARequestResult *result);
typedef void (^SAProfileCallback) (SAUserObject *user);
