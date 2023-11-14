//
//  TimestampEditCell.m
//  SMBox
//
//  Created by Alisa Nekrasova on 30/12/14.
//  Copyright (c) 2014 LVWebGuy. All rights reserved.
//

#import "TimestampEditCell.h"

@interface TimestampEditCell()
{
	ATSDragToReorderTableViewController *_ats;
	Timestamp *_timestamp;
}
@end

@implementation TimestampEditCell

-(void)setUpWithDelegate:(id <MCSwipeTableViewCellDelegate>)delegate ats:(ATSDragToReorderTableViewController *)ats timestamp:(Timestamp *)timestamp
{
	self.defaultColor = [UIColor orangeColor];
	self.delegate = delegate;
	self.showsReorderControl = YES;
	_ats = ats;
	_timestamp = timestamp;
}

-(void)setForEdit:(BOOL)forEdit
{
	_lblTimestampName.text = forEdit ? @"T-stamp Name" : _timestamp.name;
	_lblOnRecord.hidden = !forEdit;
	_lblTimestampOptions.hidden = !forEdit;
	NSString *saveTitle = forEdit ? @"SAVE" : @" EDIT";
	[_btnSave setTitle:saveTitle forState:UIControlStateNormal];
	_btnSelect.hidden = !forEdit;
	_tfTimestampName.hidden = !forEdit;
	_tfTimestampName.text = _timestamp.name;
	if (forEdit && (_tfTimestampName.text.length == 0))
	{
		double delayInSeconds = 0.8;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			//code to be executed on the main queue after delay
			[_tfTimestampName becomeFirstResponder];
		});
	}
	
	if (forEdit)
		[self setDragElement:nil];
	else
		[self setDragElement:_ivDragHandle];
	
	_ats.touchArea = _ivDragHandle.frame;
	
	_ivIndicator.hidden = !forEdit || ((_timestamp.startOnRecord.count == 0) && (_timestamp.stopOnRecord.count == 0));
}

@end
