//
//  Scholica.h
//  Created by Tom Schoffelen on 21-04-14.
//

#import "ScholicaLoginController.h"
#import "ScholicaConstants.h"
#import "ScholicaRequestResult.h"
#import "ScholicaRequestError.h"

@interface Scholica : NSObject

@property (nonatomic) NSString* endPoint;
@property (nonatomic) NSString* authEndPoint;
@property (nonatomic) NSString* consumerKey;
@property (nonatomic) NSString* consumerSecret;

@property (nonatomic) BOOL customLoginProcess;
@property (nonatomic) BOOL customDismissLoginController;

@property (nonatomic) NSString* accessToken;
@property (nonatomic) NSString* requestToken;

- (id) initWithConsumerKey:(NSString*)consumerKey secret:(NSString*)consumerSecret;

- (void) loginInViewController:(UIViewController*)viewController success:(ScholicaLoginCallback)success failure:(ScholicaLoginCallback)failure;

- (void) getRequestToken:(ScholicaRequestCallback)callback;

- (void) request:(NSString*)method withFields:(NSDictionary*)fields callback:(ScholicaRequestCallback)callback;
- (void) request:(NSString*)method callback:(ScholicaRequestCallback)callback;

@end