//
//  TotalEditCell.h
//  SMBox
//
//  Created by Alisa Nekrasova on 30/12/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#import "Total.h"
#import "ATSDragToReorderTableViewController.h"

@interface TotalEditCell : MCSwipeTableViewCell

@property (strong) IBOutlet UIImageView *ivDragHandle;
@property (strong) IBOutlet UILabel *lblTotalName;
@property (strong) IBOutlet UITextField *tfTotalName;
@property (strong) IBOutlet UIButton *btnSave;
@property (strong) IBOutlet UILabel *lblTotalOptions;
@property (strong) IBOutlet UIButton *btnSelect;

-(void)setUpWithDelegate:(id <MCSwipeTableViewCellDelegate>)delegate ats:(ATSDragToReorderTableViewController *)ats total:(Total *)total;
-(void)setForEdit:(BOOL)forEdit;

@end
