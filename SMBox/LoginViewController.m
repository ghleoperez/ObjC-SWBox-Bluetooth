//
//  LoginViewController.m
//  SMBox
//
//  Created by Alisa Nekrasova on 22/08/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "KeychainItemWrapper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController ()
{
	CGRect loginFrame;
	UITapGestureRecognizer *tap;
	BOOL regMode;
}
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	regMode = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)forgetCredentials
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	UserMgr *userMgr = appDelegate.userMgr;
	[userMgr clearUserDetails:self];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	loginFrame = _vLoginFrame.frame;
	
	_btnLogin.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
	_btnLogin.layer.borderWidth = 1.0f;
	_btnRegister.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
	_btnRegister.layer.borderWidth = 1.0f;
	_btnOffline.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.7].CGColor;
	_btnOffline.layer.borderWidth = 1.0f;
	
	// register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	tap = [[UITapGestureRecognizer alloc]
		   initWithTarget:self
		   action:@selector(dismissKeyboard)];
	
	[self.view addGestureRecognizer:tap];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
	
	// unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillShowNotification
												  object:nil];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIKeyboardWillHideNotification
												  object:nil];
	
	[self.view removeGestureRecognizer:tap];
	tap = nil;
}

-(void)loginToRegister
{
	[UIView animateWithDuration:0.5f animations:^{
		_btnRegister.alpha = 0.0f;
		_btnLogin.alpha = 0.0f;
		_btnOffline.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[_btnOffline setTitle:@"BACK TO LOGIN" forState:UIControlStateNormal];
		_btnLogin.hidden = YES;
		_tfConfirmPassword.hidden = NO;
		_tfEMail.hidden = NO;
		_tfConfirmPassword.alpha = 0.0f;
		_tfEMail.alpha = 0.0f;
		[UIView animateWithDuration:0.5f animations:^{
			_btnRegister.alpha = 1.0f;
			_tfConfirmPassword.alpha = 1.0f;
			_tfEMail.alpha = 1.0f;
			_btnOffline.alpha = 1.0f;
		} completion:^(BOOL finished) {
			regMode = YES;
		}];
	}];
}

-(void)registerToLogin
{
	[UIView animateWithDuration:0.5f animations:^{
		_btnRegister.alpha = 0.0f;
		_tfConfirmPassword.alpha = 0.0f;
		_tfEMail.alpha = 0.0f;
		_btnOffline.alpha = 0.0f;
	} completion:^(BOOL finished) {
		[_btnOffline setTitle:@"WORK OFFLINE" forState:UIControlStateNormal];
		_btnLogin.hidden = NO;
		_tfConfirmPassword.hidden = YES;
		_tfEMail.hidden = YES;
		_btnLogin.alpha = 0.0f;
		[UIView animateWithDuration:0.5f animations:^{
			_btnRegister.alpha = 1.0f;
			_btnLogin.alpha = 1.0f;
			_btnOffline.alpha = 1.0f;
		} completion:^(BOOL finished) {
			regMode = NO;
		}];
	}];
}

-(IBAction)login:(id)sender
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.userMgr userDidSignIn:_tfLogin.text :_tfPassword.text :self.view completion:^(bool loginSuccess) {
		if (loginSuccess)
		{
			// User logged in. Sync
			[appDelegate.userMgr getMetadataWithCompletion:^(time_t remotetime, NSString *deviceType, NSString *appVersion) {
				time_t localtime = (time_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"last_use"] longValue];
				if (remotetime > localtime)
				{
					// Remote version is newer. Download and update
					[appDelegate.userMgr getDataWithCompletion:^(NSString *data) {
						// Parse data
						[self doParsing:data];
						
						[self dismissViewControllerAnimated:YES completion:nil];
					}];
				}
				else
				{
					[self dismissViewControllerAnimated:YES completion:nil];
				}
			}];
		}
		else
		{
			// User not logged in
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Please, check login and password, try again later or start work offline" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
	}];
}

-(IBAction)loginFB:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    if ([FBSDKAccessToken currentAccessToken]) {
        [login logOut];
    }
    else {
        [login
         logInWithPermissions: @[@"public_profile", @"email"]
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                 [alert show];
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
             } else {
                 // ...
//                 [FBSDKProfile loadCurrentProfileWithCompletion:
//                  ^(FBSDKProfile *user, NSError *error) {
//                      if (user) {
//                          NSString *firstName = user.firstName;
//                          NSString *lastName = user.lastName;
//                          NSString *facebookId = user.userID;
//                          
//                          NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
//                          [parameters setValue:@"id,name,email" forKey:@"fields"];
//                          
//                          [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
//                           startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
//                                                        id result, NSError *error) {
//                               NSString *email = [result objectForKey:@"email"];
//                               AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                               [appDelegate.userMgr facebookUserDidRegister:facebookId
//                                                                  firstname:firstName
//                                                                   lastname:lastName
//                                                                      email:email
//                                                                currentView:self.view
//                                                                 completion:^(bool didRegister) {
//                                                                     if (didRegister) {
//                                                                         [self dismissViewControllerAnimated:YES completion:nil];
//                                                                     }
//                                                                     else {
//                                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Facebook login failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                                                                         [alert show];
//                                                                     }
//                                                                 }];
//                           }];
//                      }
//                      else {
//                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Couldn't get profile" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//                          [alert show];
//                      }
//                  }];
             }
         }];
    }
}

/*
-(IBAction)loginFB:(id)sender
{
	// If the session state is any of the two "open" states when the button is clicked
	if (FBSession.activeSession.state == FBSessionStateOpen
		|| FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
		
		// Close the session and remove the access token from the cache
		// The session state handler (in the app delegate) will be called automatically
		[FBSession.activeSession closeAndClearTokenInformation];
		
  // If the session state is not any of the two "open" states when the button is clicked
	} else {
		// Open a session showing the user the login UI
		// You must ALWAYS ask for public_profile permissions when opening a session
		[FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
										   allowLoginUI:YES
									  completionHandler:
		 ^(FBSession *session, FBSessionState state, NSError *error) {
			 
			 if (FBSession.activeSession.isOpen) {
				 
				 [[FBRequest requestForMe] startWithCompletionHandler:
				  ^(FBRequestConnection *connection,
		   NSDictionary<FBGraphUser> *user,
		   NSError *error) {
					  if (!error) {
						  NSString *firstName = user.first_name;
						  NSString *lastName = user.last_name;
						  NSString *facebookId = user.objectID;
						  NSString *email = [user objectForKey:@"email"];
						  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
						  [appDelegate.userMgr facebookUserDidRegister:facebookId
															 firstname:firstName
															  lastname:lastName
																 email:email
														   currentView:self.view
															completion:^(bool didRegister) {
																if (didRegister) {
																	[self dismissViewControllerAnimated:YES completion:nil];
																}
																else {
																	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Facebook login failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
																	[alert show];
																}
															}];
					  }
				  }];
			 }
		 }];
	}
}
*/

-(IBAction)loginTW:(id)sender
{
	
}

-(IBAction)reg:(id)sender
{
	if (!regMode) {
		[self loginToRegister];
		return;
	}
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	if (![appDelegate.userMgr verifyRegistratonForm:_tfLogin.text :_tfPassword.text :_tfConfirmPassword.text :_tfEMail.text])
		return;

	[appDelegate.userMgr userDidRegister:_tfLogin.text :_tfPassword.text :_tfEMail.text :self.view completion:^(bool didRegister) {
		if (didRegister)
		{
			// User registered, don't need to sync. Just log in
			[appDelegate.userMgr userDidSignIn:_tfLogin.text :_tfPassword.text :self.view completion:^(bool loginSuccess) {
				if (loginSuccess)
				{
					// User logged in. No sync
					[self dismissViewControllerAnimated:YES completion:nil];
				}
				else
				{
					// User not logged in
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"You were successfully registered, but log in failed. Please, try to log in later or start work offline" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alert show];
				}
			}];
		}
		else
		{
			// User not registered
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Error happened during registration. If you are already registered, just log in, otherwise try again later or start work offline" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
		}
	}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _tfLogin)
		[_tfPassword becomeFirstResponder];
	else if (textField == _tfPassword)
	{
		[_tfPassword resignFirstResponder];
		[self login:textField];
	}
	else if (textField == _tfEMail)
		[_tfConfirmPassword becomeFirstResponder];
	else if (textField == _tfConfirmPassword)
	{
		[_tfConfirmPassword resignFirstResponder];
		[self reg:textField];
	}
	else
		return YES;
	
	return NO;
}

-(void)dismissKeyboard {
	[_tfConfirmPassword resignFirstResponder];
	[_tfEMail resignFirstResponder];
	[_tfLogin resignFirstResponder];
	[_tfPassword resignFirstResponder];
}

-(void)setViewMovedUp:(BOOL)moved
{
	[UIView animateWithDuration:0.3f animations:^{
		CGRect frame = loginFrame;
		if (moved)
			frame.origin.y = 0;
		
		_vLoginFrame.frame = frame;
		
		frame = self.view.frame;
		if (moved)
			frame.origin.y = -78;
		else
			frame.origin.y = 0;
		
		self.view.frame = frame;
	}];
}

// Keyboard
-(void)keyboardWillShow:(NSNotification*)notification {
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
	[self setViewMovedUp:NO];
}

-(void)offline:(id)sender
{
	if (regMode) {
		[self registerToLogin];
		return;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
