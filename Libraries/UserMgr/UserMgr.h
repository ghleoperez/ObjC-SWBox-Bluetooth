//
//  UserMgr.h
//  UserMgr
//
//  Created by Justin on 2/7/14.
//  Copyright (c) 2014 ttgspeed. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kIdentifier;

@interface UserMgr : NSObject

//register
- (void)userDidRegister:(NSString*)username :(NSString*)password :(NSString*)email :(UIView*)currentView completion:(void (^)(bool didRegister))completionBlock;

//fb register
- (void)facebookUserDidRegister:
                    (NSString *)fb_id
                      firstname:(NSString *)firstname
                       lastname:(NSString *)lastname
                          email:(NSString *)email
                    currentView:(UIView*)currentView
                     completion:(void (^)(bool didRegister))completionBlock;

//twitter register
- (void)twitterUserDidRegister:(NSString *)tw_id :(NSString *)tw_username currentView:(UIView*)currentView
                     completion:(void (^)(bool didRegister))completionBlock;

//sign in
- (void)userDidSignIn:(NSString*)username :(NSString*)password :(UIView*)currentView completion:(void (^)(bool loginSuccess))completionBlock;

- (void)restoreSession:(UIView*)currentView completion:(void (^)(bool loginSuccess))completionBlock;

//verification
- (BOOL)verifyRegistratonForm:(NSString*)username :(NSString*)password :(NSString*)passwordConfirm
                             :(NSString*)email;

//reset password
- (void)userDidRequestPasswordReset:(NSString*)username :(UIView*)currentView completion:(void (^)(bool didRecover))completionBlock;

//user details
- (void)clearUserDetails:(id)sender;

- (BOOL)userDetailsAreSaved:(id)sender;

- (void)saveUserDetailsFacebook:(NSString*)fb_id :(NSString*)firstname :(NSString*)lastname
                               :(NSString*)email;

- (void)saveUserDetailsTwitter:(NSString*)tw_username;

//sync the data
- (void)saveData:(NSString *)data;

- (void)getDataWithCompletion:(void (^)(NSString *data))completionBlock;

- (void)getMetadataWithCompletion:(void (^)(time_t timestamp, NSString *deviceType, NSString *appVersion))completionBlock;

@end
