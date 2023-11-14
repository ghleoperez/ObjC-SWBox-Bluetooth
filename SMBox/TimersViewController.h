//
//  TimersViewController.h
//  SMBox
//
//  Created by Alisa Nekrasova on 06/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MCSwipeTableViewCell.h"

#import "Project.h"

@interface TimersViewController : UIViewController <MFMailComposeViewControllerDelegate, MCSwipeTableViewCellDelegate>

@property (assign) IBOutlet UITableView *tvTimers;
@property (assign) IBOutlet UILabel *lblHead;
@property (assign) IBOutlet UILabel *lblHeadTime;

-(void)setProject:(Project *)project;

-(IBAction)clearAllTimers:(id)sender;
-(IBAction)backToProduction:(id)sender;
-(IBAction)backToProjects:(id)sender;
-(IBAction)sendEMail:(id)sender;
-(IBAction)showHideCurrentTime:(id)sender;

@end
