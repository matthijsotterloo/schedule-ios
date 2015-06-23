//
//  SSDataProvider.h
//  
//
//  Created by Thomas Schoffelen on 13/06/15.
//
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "SSSchoolViewController.h"
#import "Scholica.h"

@interface SSDataProvider : SASingleton

@property (strong, nonatomic) NSString* provider;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* site;
@property (strong, nonatomic) NSString* endPoint;

- (id) initWithProvider:(NSString*) provider;
- (void) setProvider:(NSString *)provider;
- (void) setProvider:(NSString *)provider site:(NSString *)site username:(NSString *)username password:(NSString *)password;

- (BOOL) getSession;
- (void) saveSession;
- (void) signOut;

- (void) profile:(SAProfileCallback)callback;
- (void)getCalendarWithTimestamp:(NSNumber *)time callback:(SARequestCallback)callback;

- (void)getGrades:(SARequestCallback)callback;
- (void)getHomework:(SARequestCallback)callback;
- (void)prefillListForProvider:(NSString*)provider controller:(UIViewController*)controller;
- (void)getSchoolsForProvider:(NSString*)provider searchText:(NSString*)searchText controller:(UIViewController*)controller;

+ (void)invokeLoginDialogForProvider:(NSString*)provider site:(NSString*)site title:(NSString*)title;

@end
