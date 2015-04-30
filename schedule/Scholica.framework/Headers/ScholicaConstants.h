//
//  ScholicaContstants.h
//  Created by Tom Schoffelen on 21-04-14.
//

@class ScholicaRequestResult;

typedef enum {
    ScholicaLoginStatusOK,                  // No problems here
    ScholicaLoginStatusInvalidConsumer,     // The supplied consumer_key is invalid or blocked
    ScholicaLoginStatusCanceledByUser,      // The user canceled the login request
    ScholicaLoginStatusNetworkError,        // Network error (could not load frame)
    ScholicaLoginStatusUnknown              // Unknown error
} ScholicaLoginStatus;

typedef enum {
    ScholicaRequestStatusOK,                  // No problems here
    ScholicaRequestStatusError                // Error occurred
} ScholicaRequestStatus;

typedef void (^ScholicaLoginCallback) (ScholicaLoginStatus status);
typedef void (^ScholicaLoginControllerCallback) ();
typedef void (^ScholicaRequestCallback) (ScholicaRequestResult* result);
