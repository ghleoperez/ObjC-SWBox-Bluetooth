//
//  TotalEditCell.m
//  SMBox
//
//  Created by Alisa Nekrasova on 30/12/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "TotalEditCell.h"

@interface TotalEditCell()
{
	ATSDragToReorderTableViewController *_ats;
	Total *_total;
}
@end

@implementation TotalEditCell

-(void)setUpWithDelegate:(id <MCSwipeTableViewCellDelegate>)delegate ats:(ATSDragToReorderTableViewController *)ats total:(Total *)total
{
	self.defaultColor = [UIColor orangeColor];
	self.delegate = delegate;
	self.showsReorderControl = YES;
	_ats = ats;
	_total = total;
}

-(void)setForEdit:(BOOL)forEdit
{
	_lblTotalName.text = forEdit ? @"Total Name" : _total.name;
	_lblTotalOptions.hidden = !forEdit;
	NSString *saveTitle = forEdit ? @"SAVE" : @" EDIT";
	[_btnSave setTitle:saveTitle forState:UIControlStateNormal];
	_btnSelect.hidden = !forEdit;
	_tfTotalName.hidden = !forEdit;
	_tfTotalName.text = _total.name;
	if (forEdit && (_tfTotalName.text.length == 0))
	{
		double delayInSeconds = 0.8;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			//code to be executed on the main queue after delay
			[_tfTotalName becomeFirstResponder];
		});
	}
	
	if (forEdit)
		[self setDragElement:nil];
	else
		[self setDragElement:_ivDragHandle];
	
	_ats.touchArea = _ivDragHandle.frame;
}

@end
