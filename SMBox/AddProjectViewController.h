//
//  AddProjectViewController.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NKColorSwitch.h"
#import "Project.h"

#import "WEPopoverController.h"
#import "ColorViewController.h"

@interface AddProjectViewController : UIViewController<ColorViewControllerDelegate, WEPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//@property (assign) IBOutlet NKColorSwitch *swiUseTimes;
//@property (assign) IBOutlet UILabel *lblUseTimes;
@property (assign) IBOutlet UITextField *tfShortName;
@property (assign) IBOutlet UITextField *tfLongName;
@property (assign) IBOutlet UITextField *tfEmailRecipient;
@property (assign) IBOutlet UIButton *btnCreate;

-(void) setCreate;
-(void) setEdit:(Project *)project;

-(IBAction)create:(id)sender;
-(IBAction)chooseColor:(id)sender;
-(IBAction)chooseImage:(id)sender;

@end
