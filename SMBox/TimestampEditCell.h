//
//  TimestampEditCell.h
//  SMBox
//
//  Created by Alisa Nekrasova on 30/12/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#import "ATSDragToReorderTableViewController.h"
#import "Timestamp.h"

@interface TimestampEditCell : MCSwipeTableViewCell

@property (strong) IBOutlet UIImageView *ivDragHandle;
@property (strong) IBOutlet UILabel *lblTimestampName;
@property (strong) IBOutlet UITextField *tfTimestampName;
@property (strong) IBOutlet UIButton *btnSave;
@property (strong) IBOutlet UILabel *lblTimestampOptions;
@property (strong) IBOutlet UILabel *lblOnRecord;
@property (strong) IBOutlet UIButton *btnSelect;
@property (strong) IBOutlet UIImageView *ivIndicator;

-(void)setUpWithDelegate:(id <MCSwipeTableViewCellDelegate>)delegate ats:(ATSDragToReorderTableViewController *)ats timestamp:(Timestamp *)timestamp;
-(void)setForEdit:(BOOL)forEdit;

@end
