//
//  AppDelegate.m
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "Appirater.h"
#import "UserVoice.h"
#import "UVStyleSheet.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate
{
	time_t _goBackgroundTimer;
	NSThread *_thread;
	BOOL _inTutorial;
	UIViewController *tutorialController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[Fabric with:@[CrashlyticsKit]];

	_projects = [[Projects alloc] init];
	_goBackgroundTimer = time(NULL);
	_thread = [[NSThread alloc] initWithTarget:self selector:@selector(inThread) object:nil];
	[_thread start];
	[Appirater setAppId:@""];
	[Appirater setUsesUntilPrompt:10];
	
	_userMgr = [[UserMgr alloc] init];
	
	[Appirater appLaunched:YES];
	[Appirater userDidSignificantEvent:YES];
	
	// Whenever a person opens app, check for a cached session
    /*
	if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
		// If there's one, just open the session silently, without showing the user the login UI
		[FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
										   allowLoginUI:NO
									  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
										  [self sessionStateChanged:session state:state error:error];
									  }];
	}
     */
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
	
    return YES;
}

- (void)inThread
{
	time_t t = time(NULL);
	time_t newT = time(NULL);
	while (1)
	{
		newT = time(NULL);
		if (t != newT)
		{
			t = newT;
			[_activeProject tick];
		}
		[NSThread sleepForTimeInterval:0.01];
	}
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                    ];
    // Add any custom logic here.
    return handled;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	_goBackgroundTimer = time(NULL);
	[_projects saveToFile];
	[_projects sendToServer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	[Appirater appEnteredForeground:YES];
	
	time_t diff = time(NULL) - _goBackgroundTimer;
	if ((diff > 0) && _activeProject)
	{
		[_activeProject tick:(int)diff];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [FBAppCall handleDidBecomeActive];
	
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[_projects saveToFile];
	[_projects sendToServer];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
	if (isPad())
	    return UIInterfaceOrientationMaskAll;
	else
		return UIInterfaceOrientationMaskPortrait;
}

- (void)facebookUserLoggedIn
{
	
}

- (void)facebookUserLoggedOut
{

}

// Handles session state changes in the app
/*
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
	// If the session was opened successfully
	if (!error && state == FBSessionStateOpen){
		NSLog(@"Session opened");
		// Show the user the logged-in UI
		[self facebookUserLoggedIn];
		return;
	}
	if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
		// If the session is closed
		NSLog(@"Session closed");
		// Show the user the logged-out UI
		[self facebookUserLoggedOut];
	}
	
	// Handle errors
	if (error){
		NSLog(@"Error");
		NSString *alertText;
		NSString *alertTitle;
		// If the error requires people using an app to make an action outside of the app in order to recover
		if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
			alertTitle = @"Something went wrong";
			alertText = [FBErrorUtility userMessageForError:error];
			//[self showMessage:alertText withTitle:alertTitle];
		} else {
			
			// If the user cancelled login, do nothing
			if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
				NSLog(@"User cancelled login");
				
				// Handle session closures that happen outside of the app
			} else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
				alertTitle = @"Session Error";
				alertText = @"Your current session is no longer valid. Please log in again.";
				//[self showMessage:alertText withTitle:alertTitle];
				
				// Here we will handle all other errors with a generic error message.
				// We recommend you check our Handling Errors guide for more information
				// https://developers.facebook.com/docs/ios/errors/
			} else {
				//Get more error information from the error
				NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
				
				// Show the user an error message
				alertTitle = @"Something went wrong";
				alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
				//[self showMessage:alertText withTitle:alertTitle];
			}
		}
		// Clear this token
		[FBSession.activeSession closeAndClearTokenInformation];
		// Show the user the logged-out UI
		[self facebookUserLoggedOut];
	}
}
*/
@end

BOOL isPad() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}
