//
//  TimerEditCell.h
//  SMBox
//
//  Created by Alisa Nekrasova on 30/12/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#import "NKColorSwitch.h"
#import "NovecentoTextField.h"
#import "ATSDragToReorderTableViewController.h"
#import "Timer.h"

@interface TimerEditCell : MCSwipeTableViewCell

@property (strong) IBOutlet UIImageView *ivDragHandle;
@property (strong) IBOutlet UILabel *lblTimerName;
@property (strong) IBOutlet UIButton *btnSave;
@property (strong) IBOutlet UITextField *tfTimerName;

// Count Up
@property (strong) IBOutlet UILabel *lblCountUpName;
@property (strong) IBOutlet NKColorSwitch *swiCountUp;
@property (strong) IBOutlet UILabel *lblCountUpValue;

// Count Down
@property (strong) IBOutlet UILabel *lblCountDownName;
@property (strong) IBOutlet NKColorSwitch *swiCountDown;
@property (strong) IBOutlet UILabel *lblCountDownValue;

// From
@property (strong) IBOutlet UILabel *lblFromName;
@property (strong) IBOutlet NovecentoTextField *tfFromValue;

// OnTimerStart
@property (strong) IBOutlet UILabel *lblOnTimerStartName;
@property (strong) IBOutlet UIButton *btnOnTimerStartSelect;
@property (strong) IBOutlet UIImageView *ivOnTimerStartIndicator;

// OnTimerStop
@property (strong) IBOutlet UILabel *lblOnTimerStopName;
@property (strong) IBOutlet UIButton *btnOnTimerStopSelect;
@property (strong) IBOutlet UIImageView *ivOnTimerStopIndicator;

-(void)setUpWithDelegate:(id <MCSwipeTableViewCellDelegate>)delegate ats:(ATSDragToReorderTableViewController *)ats timer:(Timer *)timer;
-(void)setForEdit:(BOOL)forEdit fromSwitch:(BOOL)fromSwitch;

@end
