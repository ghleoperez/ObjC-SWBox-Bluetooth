//
//  UserMgr.m
//  UserMgr
//
//  Created by Justin on 2/7/14.
//  Copyright (c) 2014 ttgspeed. All rights reserved.
//

#import "UserMgr.h"
#import <AFNetworking.h>
#import "MBProgressHUD.h"
//#import "MBHUDView.h"
#import "KeychainItemWrapper.h"
#import "SBJson4.h"

@implementation UserMgr

static NSString *const loginUrl = @"http://backstageapps.com/SMUM/core/ios/function.login.php";
static NSString *const registerUrl = @"http://backstageapps.com/SMUM/core/ios/function.register.php";
static NSString *const recoverUrl = @"http://backstageapps.com/SMUM/core/ios/function.initreset.php";
static NSString *const FBRegisterUrl = @"http://backstageapps.com/SMUM/core/ios/function.facebook.register.php";
static NSString *const TWRegisterUrl = @"http://backstageapps.com/SMUM/core/ios/function.twitter.register.php";
static NSString *const setUrl = @"http://backstageapps.com/SMUM/core/ios/function.set.php";
static NSString *const getdataUrl = @"http://backstageapps.com/SMUM/core/ios/function.getdata.php";
static NSString *const getmetadataUrl = @"http://backstageapps.com/SMUM/core/ios/function.getmetadata.php";

/*
static NSString *const loginUrl = @"http://smbox:8888/SMUM/core/ios/function.login.php";
static NSString *const registerUrl = @"http://smbox:8888/SMUM/core/ios/function.register.php";
static NSString *const recoverUrl = @"http://smbox:8888/SMUM/core/ios/function.initreset.php";
static NSString *const FBRegisterUrl = @"http://smbox:8888/SMUM/core/ios/function.facebook.register.php";
static NSString *const TWRegisterUrl = @"http://smbox:8888/SMUM/core/ios/function.twitter.register.php";
static NSString *const setUrl = @"http://smbox:8888/SMUM/core/ios/function.set.php";
static NSString *const getdataUrl = @"http://smbox:8888/SMUM/core/ios/function.getdata.php";
static NSString *const getmetadataUrl = @"http://smbox:8888/SMUM/core/ios/function.getmetadata.php";
*/

static NSString *const kIdentifier = @"SMBox";

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr Registration Handling
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)requestRegistration:(NSString *)username password:(NSString *)password email:(NSString *)email currentView:(UIView*)currentView completion:(void (^)(NSString *registerResponse))completionBlock
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 460) ];
    HUD.label.text = @"Creating account...";
    [currentView addSubview:HUD];
    [HUD showAnimated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"username":username, @"password":password, @"email":email};
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:registerUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//            
//            completionBlock(@"3");
//            
//            NSLog(@"Registration Error: %@", error);
//        }
//        else {
//            //json "response" object from server response
//            NSString *response = [responseObject objectForKey:@"response"];
//            
//            completionBlock(response);
//            
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//        }
//    }];
//    [dataTask resume];
}

- (void)userDidRegister:(NSString*)username :(NSString*)password :(NSString*)email :(UIView*)currentView completion:(void (^)(bool didRegister))completionBlock{
    
    [self requestRegistration:username
                     password:password
                        email:email
                  currentView:currentView
                   completion:^(NSString *registerResponse){
                       if ([registerResponse compare:@"0"] == NSOrderedSame)
                       {
                           NSLog(@"Did register: %@", registerResponse);
                           //successful registration
                           completionBlock(TRUE);
                       }
                       else if ([registerResponse compare:@"1"] == NSOrderedSame)
                       {
                           // ...
//                           //user already exists
//                           MBAlertView *alert = [MBAlertView alertWithBody:@"A user with that username already exists!" cancelTitle:@"Ok" cancelBlock:nil];
//                           [alert addToDisplayQueue];
                           
                           completionBlock(FALSE);
                       }
                       else if ([registerResponse compare:@"2"] == NSOrderedSame)
                       {
                           // ...
//                           //email already exists
//                           MBAlertView *alert = [MBAlertView alertWithBody:@"A user with that email already exists!" cancelTitle:@"Ok" cancelBlock:nil];
//                           [alert addToDisplayQueue];
                           
                           completionBlock(FALSE);
                       }
                       else{
                           //unsuccessful login - other error
                           completionBlock(FALSE);
                           // ...
//                           //generic error message to go with failed login
//                           MBAlertView *alert = [MBAlertView alertWithBody:@"There was an error registering your account. Please try again later." cancelTitle:@"Ok" cancelBlock:nil];
//                           [alert addToDisplayQueue];
                       }
                   }];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr SignIn Handling
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)requestSignIn:(NSString *)username password:(NSString *)password currentView:(UIView*)currentView completion:(void (^)(NSString *signInRequest))completionBlock
{
    NSString *dname = [[UIDevice currentDevice] name];
    
    NSString *uuid = [self getUUID];
    
    if ([username length] != 0 && [password length] != 0){
        
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 460) ];
        HUD.label.text = @"Logging in...";
        [currentView addSubview:HUD];
        [HUD showAnimated:YES];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        NSDictionary *parameters = @{@"username":username, @"password":password, @"dname":dname, @"uuid":uuid};
        
        NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:loginUrl parameters:parameters error:nil];
        // ...
//        NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//            if (error) {
//                [HUD hideAnimated:YES];
//                [HUD removeFromSuperViewOnHide];
//                
//                completionBlock(@"3");
//                
//                NSLog(@"Login Error: %@", error);
//            } else {
//                NSString *response = [responseObject objectForKey:@"response"];
//                
//                completionBlock(response);
//                
//                [HUD hideAnimated:YES];
//                [HUD removeFromSuperViewOnHide];
//            }
//        }];
//        [dataTask resume];
        
        /*
        [manager POST:loginUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            //json "response" object from server response
            NSString *response = [responseObject objectForKey:@"response"];
            
            completionBlock(response);
            
            [HUD hide:YES];
            [HUD removeFromSuperViewOnHide];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [HUD hide:YES];
            [HUD removeFromSuperViewOnHide];
            
            completionBlock(@"3");
            
            NSLog(@"Login Error: %@", error);
        }];
         */
    }
    else{
        completionBlock(@"0");
    }
}

- (void)userDidSignIn:(NSString*)username :(NSString*)password :(UIView*)currentView completion:(void (^)(bool didSignIn))completionBlock{
    
    [self requestSignIn:username
               password:password
            currentView:currentView
             completion:^(NSString *signInRequest){
                 if ([signInRequest compare:@"1"] == NSOrderedSame || [signInRequest compare:@"2"] == NSOrderedSame)
                 {
                     //successful login/1-new device/2-existing device
                     NSLog(@"Login successful");
                     
                     [self saveUserDetails:username :password];
                     completionBlock(TRUE);
                 }
                 else if ([signInRequest compare:@"0"] == NSOrderedSame)
                 {
                     //unsuccessful login - invalid password
                     NSLog(@"Login failed: invalid username/password");
                     completionBlock(FALSE);
                 }
                 else{
                     //unsuccessful login - other error
                     NSLog(@"Login failed");
                     completionBlock(FALSE);
                     // ...
//                     //generic error message to go with failed login
//                     MBAlertView *alert = [MBAlertView alertWithBody:@"There was an error signing in. Please try again later." cancelTitle:@"Ok" cancelBlock:nil];
//                     [alert addToDisplayQueue];
                 }
             }];
}

- (void)restoreSession:(UIView*)currentView completion:(void (^)(bool loginSuccess))completionBlock{
    
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
    
    NSString *username = [[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *password = [[keychainWrapper objectForKey:(__bridge id)(kSecValueData)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self userDidSignIn:username :password :currentView
             completion:^(bool didrestore){
                 if(didrestore){
                     completionBlock(TRUE);
                 }
                 else{
                     completionBlock(FALSE);
                 }
             }];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr Password Reset Handling
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)requestPasswordReset:(NSString *)username currentView:(UIView*)currentView completion:(void (^)(NSString *recoverResponse))completionBlock
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 460) ];
    HUD.label.text = @"Requesting reset...";
    [currentView addSubview:HUD];
    [HUD showAnimated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"username":username};
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:recoverUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//            
//            completionBlock(@"3");
//            
//            NSLog(@"Recovery Error: %@", error);
//        } else {
//            //json "response" object from server response
//            NSString *response = [responseObject objectForKey:@"response"];
//            
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//            
//            completionBlock([NSString stringWithFormat:@"%@",response]);
//        }
//    }];
//    [dataTask resume];
}

- (void)userDidRequestPasswordReset:(NSString *)username :(UIView *)currentView completion:(void (^)(bool didRecover))completionBlock{
    
    [self requestPasswordReset:username currentView:currentView completion:^(NSString *recoverResponse) {
        if ([recoverResponse compare:@"1"] == NSOrderedSame)
        {
            //email sent
            completionBlock(TRUE);
        }
        else if ([recoverResponse compare:@"0"] == NSOrderedSame)
        {
            //user doesn't exit
            completionBlock(FALSE);
        }
        else{
            //unsuccessful
            completionBlock(FALSE);
        }
    }];
    
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr Facebook
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)requestFacebookRegistration:(NSString *)fb_id firstname:(NSString *)firstname
                              lastname:(NSString *)lastname email:(NSString *)email
                            currentView:(UIView*)currentView completion:(void (^)(NSString *registerResponse))completionBlock
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 460) ];
    HUD.label.text = @"Verifying Registration...";
    [currentView addSubview:HUD];
    [HUD showAnimated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								fb_id, @"fb_id",
								firstname, @"firstname",
								lastname, @"lastname",
								email, @"email",
								nil];
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:FBRegisterUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//            
//            completionBlock(@"0");
//            
//            NSLog(@"Registration Error: %@", error);
//        } else {
//            //json "response" object from server response
//            NSString *response = [responseObject objectForKey:@"response"];
//            
//            completionBlock(response);
//            
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//        }
//    }];
//    [dataTask resume];
}

- (void)facebookUserDidRegister:(NSString *)fb_id firstname:(NSString *)firstname
                       lastname:(NSString *)lastname email:(NSString *)email
                          currentView:(UIView*)currentView completion:(void (^)(bool didRegister))completionBlock{
    
    [self requestFacebookRegistration:fb_id
                     firstname:firstname
                             lastname:lastname
                        email:email
                  currentView:currentView
                   completion:^(NSString* registerResponse){
                       if ([registerResponse compare:@"1"] == NSOrderedSame)
                       {
                           NSLog(@"Did register: %@", registerResponse);
                           //successful registration
                           completionBlock(TRUE);
                       }
                       else{
                           //unsuccessful login - other error
                           completionBlock(FALSE);
                           // ...
//                           //generic error message to go with failed login
//                           MBAlertView *alert = [MBAlertView alertWithBody:@"There was an error registering your account. Please try again later." cancelTitle:@"Ok" cancelBlock:nil];
//                           [alert addToDisplayQueue];
                       }
                   }];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr Twitter
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)requestTwitterRegistration:(NSString *)tw_id :(NSString *)tw_username currentView:(UIView*)currentView
                        completion:(void (^)(NSString *registerResponse))completionBlock
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 320, 460) ];
    HUD.label.text = @"Verifying Registration...";
    [currentView addSubview:HUD];
    [HUD showAnimated:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"tw_id":tw_id,@"tw_username":tw_username};
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:TWRegisterUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//            
//            completionBlock(@"0");
//            
//            NSLog(@"Registration Error: %@", error);
//        } else {
//            //json "response" object from server response
//            NSString *response = [responseObject objectForKey:@"response"];
//            
//            completionBlock(response);
//            
//            [HUD hideAnimated:YES];
//            [HUD removeFromSuperViewOnHide];
//        }
//    }];
//    [dataTask resume];
}

- (void)twitterUserDidRegister:(NSString *)tw_id :(NSString *)tw_username currentView:(UIView*)currentView
                completion:(void (^)(bool didRegister))completionBlock{
    [self requestTwitterRegistration:tw_id :tw_username
                          currentView:currentView
                           completion:^(NSString* registerResponse){
                               if ([registerResponse compare:@"1"] == NSOrderedSame)
                               {
                                   NSLog(@"Did register: %@", registerResponse);
                                   //successful registration
                                   completionBlock(TRUE);
                               }
                               else{
                                   //unsuccessful login - other error
                                   completionBlock(FALSE);
                                   // ...
//                                   //generic error message to go with failed login
//                                   MBAlertView *alert = [MBAlertView alertWithBody:@"There was an error registering your account. Please try again later." cancelTitle:@"Ok" cancelBlock:nil];
//                                   [alert addToDisplayQueue];
                               }
                           }];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr User Detail Management
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)saveUserDetails:(NSString*)username :(NSString*)password{
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"loginType"];
    
    [keychainWrapper setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [keychainWrapper setObject:password forKey:(__bridge id)(kSecValueData)];
}

- (void)saveUserDetailsFacebook:(NSString*)fb_id :(NSString*)firstname :(NSString*)lastname
                               :(NSString*)email{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"loginType"];
    
    [[NSUserDefaults standardUserDefaults] setObject:fb_id forKey:@"fb_id"];
    [[NSUserDefaults standardUserDefaults] setObject:firstname forKey:@"fb_firstName"];
    [[NSUserDefaults standardUserDefaults] setObject:lastname forKey:@"fb_lastName"];
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"fb_email"];
    
    NSLog(@"User Facebook details saved");
}

- (void)saveUserDetailsTwitter:(NSString*)tw_username{
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"loginType"];
    
    [[NSUserDefaults standardUserDefaults] setObject:tw_username forKey:@"tw_username"];
    
    NSLog(@"User Twitter username saved");
}

- (BOOL)userDetailsAreSaved:(id)sender{
    
    NSString *loginType = [[NSUserDefaults standardUserDefaults] stringForKey:@"loginType"];
    
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
    
    NSString *username = [[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *password = [[keychainWrapper objectForKey:(__bridge id)(kSecValueData)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return(username.length == 0 & password.length == 0 &[loginType compare:@"0"] == NSOrderedSame)?FALSE:TRUE;
    
    
}

- (void)clearUserDetails:(id)sender{
    
    NSLog(@"Clearing all saved user details");
    
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
    
    [keychainWrapper resetKeychainItem];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"loginType"];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fb_id"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fb_firstName"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fb_lastName"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"fb_email"];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tw_username"];
    
    
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UserMgr Misc Functions
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (BOOL)verifyRegistratonForm:(NSString*)username :(NSString*)password :(NSString*)passwordConfirm
                             :(NSString*)email{
    //verify that the form is filled out
    if([username length] != 0 & [password length] != 0 & [passwordConfirm length] != 0 &
       [email length] != 0)
    {
        //verify the passwords match
        if([password compare:passwordConfirm] == NSOrderedSame){
            return TRUE;
        }
        else{
            // ...
//            MBAlertView *alert = [MBAlertView alertWithBody:@"Your passwords do not match" cancelTitle:@"Ok" cancelBlock:nil];
//            [alert addToDisplayQueue];
            
            return FALSE;
        }
    }
    else{
        // ...
//        MBAlertView *alert = [MBAlertView alertWithBody:@"Please fill out all fields" cancelTitle:@"Ok" cancelBlock:nil];
//        [alert addToDisplayQueue];
        
        return FALSE;
    }
}

-(NSString *)getUUID
{
    
    //get the saved uuid (this may be nil, but we'll check that in a second
    NSString *savedUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceUUID"];
    
    NSLog(@"Saved UUID: %@", savedUUID);
    
    if ([savedUUID length] == 0) {
        //there's no saved uuid, so generate a new one
        CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
        NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
        CFRelease(newUniqueId);
        
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:@"deviceUUID"];
        
        //force the uuid to be saved (mostly useful for xcode debugging)
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Saving new UUID: %@", uuidString);
        
        savedUUID = uuidString;
    }
    
    return savedUUID;
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Data Sync Functions
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void)saveData:(NSString *)data
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] == nil)
		return;
	
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
	
	NSString *user_id = nil;
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 0)
	{
		KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
		user_id = [[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 1)
		user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_id"];
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 2)
		user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"tw_username"];
    
	if (user_id == nil)
		return;
	
    NSDictionary *parameters = @{@"user_id"		: user_id,
								 @"is_social"	: [[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"],
								 @"device_type"	: @"iOS",
								 @"app_version"	: @"2.0",
								 @"data"		: data };
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:setUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        
//    }];
//    [dataTask resume];
}

- (void)getDataWithCompletion:(void (^)(NSString *data))completionBlock
{
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
	
	NSString *user_id = nil;
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 0)
	{
		KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
		user_id = [[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 1)
		user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_id"];
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 2)
		user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"tw_username"];
    
	if (user_id == nil)
	{
		completionBlock(nil);
		return;
	}
    
    NSDictionary *parameters = @{@"user_id"		:user_id,
								 @"is_social"	:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"]};
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:getdataUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            completionBlock(nil);
//        } else {
//            NSString *response = [responseObject objectForKey:@"data"];
//            
//            completionBlock(response);
//        }
//    }];
//    [dataTask resume];
}

- (void)getMetadataWithCompletion:(void (^)(time_t timestamp, NSString *deviceType, NSString *appVersion))completionBlock
{
	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
	
	NSString *user_id = nil;
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 0)
	{
		KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kIdentifier accessGroup:nil];
		user_id = [[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 1)
		user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"fb_id"];
	else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"] intValue] == 2)
		user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"tw_username"];
    
	if (user_id == nil)
	{
		completionBlock(0, @"", @"");
		return;
	}
    
	NSString *strLocaltime = [NSString stringWithFormat:@"%ld", time(NULL)];
    NSDictionary *parameters = @{@"user_id"		:user_id,
								 @"localtime"	:strLocaltime,
								 @"is_social"	:[[NSUserDefaults standardUserDefaults] objectForKey:@"loginType"]};
    
    NSURLRequest *request =  [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:getmetadataUrl parameters:parameters error:nil];
    // ...
//    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        if (error) {
//            completionBlock(0, @"", @"");
//        } else {
//            NSLog(@"%@", responseObject);
//            
//            time_t res_timestamp = [[responseObject objectForKey:@"timestamp"] longValue];
//            NSString *res_deviceType = [responseObject objectForKey:@"device_type"];
//            NSString *res_appVersion = [responseObject objectForKey:@"app_version"];
//            
//            completionBlock(res_timestamp, res_deviceType, res_appVersion);
//        }
//    }];
//    [dataTask resume];
}


@end
