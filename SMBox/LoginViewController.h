//
//  LoginViewController.h
//  SMBox
//
//  Created by Alisa Nekrasova on 22/08/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParserViewController.h"

@interface LoginViewController : ParserViewController

@property (strong) IBOutlet UIView *vLoginFrame;
@property (strong) IBOutlet UITextField *tfLogin;
@property (strong) IBOutlet UITextField *tfPassword;
@property (strong) IBOutlet UITextField *tfConfirmPassword;
@property (strong) IBOutlet UITextField *tfEMail;
@property (strong) IBOutlet UIButton *btnLogin;
@property (strong) IBOutlet UIButton *btnRegister;
@property (strong) IBOutlet UIButton *btnOffline;
@property (strong) IBOutlet UIButton *btnFacebook;
@property (strong) IBOutlet UIButton *btnTwitter;

-(IBAction)login:(id)sender;
-(IBAction)loginFB:(id)sender;
-(IBAction)loginTW:(id)sender;
-(IBAction)reg:(id)sender;
-(IBAction)offline:(id)sender;

@end
