//
//  ProductionViewController.h
//  SMBox
//
//  Created by Alisa Nekrasova on 05/02/14.
//  Copyright (c) 2014 Backstage Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCSwipeTableViewCell.h"
#import "Project.h"
#import "ATSDragToReorderTableViewController.h"

@interface ProductionViewController : UIViewController <MCSwipeTableViewCellDelegate, UIGestureRecognizerDelegate, ATSDragToReorderTableViewControllerDelegate>

@property (assign) IBOutlet UIView *vAdd;
@property (assign) IBOutlet UIView *vTimers;
@property (assign) IBOutlet UITableView *tvTimers;
@property (assign) IBOutlet UILabel *lblHead;

@property (assign) IBOutlet UIView *onStartStopView;
@property (assign) IBOutlet UILabel *onStartStopHead;
@property (assign) IBOutlet UILabel *onStartStopWhen;
@property (assign) IBOutlet UIButton *onStartStopUpdate;
@property (assign) IBOutlet UITableView *onStartStopStart;
@property (assign) IBOutlet UITableView *onStartStopStop;

@property (assign) IBOutlet UIView *onTimersUpdateView;
@property (assign) IBOutlet UILabel *onTimersUpdateMessage;
@property (assign) IBOutlet UIButton *onTimersUpdateUpdate;
@property (assign) IBOutlet UITableView *onTimersUpdateTable;


-(void)setProject:(Project *)project;

-(IBAction)goToTimers:(id)sender;
-(IBAction)addObject:(id)sender;
-(IBAction)back:(id)sender;
-(IBAction)editTimer:(id)sender;
-(IBAction)editTotal:(id)sender;
-(IBAction)editTimestamp:(id)sender;
-(IBAction)tutorial:(id)sender;

-(IBAction)editOnTimerStart:(id)sender;
-(IBAction)editOnTimerStop:(id)sender;
-(IBAction)editOnRecord:(id)sender;
-(IBAction)updateOnStartStop:(id)sender;
-(IBAction)updateTimerUpdate:(id)sender;

-(IBAction)addTimer:(id)sender;
-(IBAction)addTimeStamp:(id)sender;
-(IBAction)addTotal:(id)sender;

@end
