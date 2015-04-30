//
//  ScholicaContstants.h
//  Scholica
//
//  Created by Thomas Schoffelen on 30/04/15.
//  Copyright (c) 2015 Scholica. All rights reserved.
//

@class ScholicaRequestResult;

typedef enum {
    ScholicaLoginStatusOK,                    // No problems here
    ScholicaLoginStatusInvalidConsumer,       // The supplied consumer_key is invalid or blocked
    ScholicaLoginStatusCanceledByUser,        // The user canceled the login request
    ScholicaLoginStatusNetworkError,          // Network error (could not load frame)
    ScholicaLoginStatusUnknown                // Unknown error
} ScholicaLoginStatus;

typedef enum {
    ScholicaRequestStatusOK,                  // No problems here
    ScholicaRequestStatusError                // Error occurred
} ScholicaRequestStatus;

typedef void (^ScholicaLoginCallback) (ScholicaLoginStatus status);
typedef void (^ScholicaLoginControllerCallback) ();
typedef void (^ScholicaRequestCallback) (ScholicaRequestResult* result);
