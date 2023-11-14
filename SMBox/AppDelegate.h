//
//  AppDelegate.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProjectsViewController.h"
#import "AddProjectViewController.h"
#import "ProductionViewController.h"
#import "TimersViewController.h"
#import "UserMgr.h"

#import "Projects.h"
#import "Project.h"

//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong) UserMgr *userMgr;

@property (strong) Project *activeProject;

@property (strong) ProjectsViewController *vcProjects;
@property (strong) AddProjectViewController *vcAddProject;
@property (strong) ProductionViewController *vcProduction;
@property (strong) TimersViewController *vcTimers;

@property (strong) Projects *projects;

@property (assign) BOOL firstProduction;

//- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end
